//
//  PlistArrayView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI
import Foundation

struct PlistArrayView: View {
	@Binding var newArray: Any
	@State var nameOfKey: String = ""
	@State var isFromDict: Bool
	@Binding var isPresented: Bool
	
	@State var values: [PlistArray] = []
	
	@State var showEditView = false
	@State var showAddView = false

	var body: some View {
		VStack {
			HStack {
				Button(action: {
					showAddView = true
				}) {
					Image(systemName: "plus")
				}
				.sheet(isPresented: $showAddView, content: {
					PlistAddArrayView(plistArray: $values, isPresented: $showAddView)
				})
				
				Spacer()
				if isFromDict {
					Text(nameOfKey)
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 40)
						}
						.font(.system(size: 40))
						.multilineTextAlignment(.center)
						.padding(-10)
						.focusable(true)
				}
				Spacer()
				Button(action: {
					newArray = values
					isPresented = false
				}) {
					Image(systemName: "checkmark")
				}
			}
			List(values.indices, id: \.self) { index in
				Button(action: {
					if values[index].type == .bool {
						values[index].value = !(values[index].value as! Bool)
					} else {
						showEditView = true
					}
				}) {
					HStack {
						if values[index].value is Bool {
							Image(systemName: values[index].value as! Bool ? "checkmark.square" : "square")
						}
						Text("\(PlistFormatter.formatAnyVarForDisplay(values[index].value)) (\(PlistFormatter.plistKeyTypeToString(values[index].type)))")
					}
				}
				.sheet(isPresented: $showEditView, content: {
					switch values[index].type {
					case .bool:
						Text("All I need is a little neurotoxin.")
					case .int:
						PlistIntView(newInt: $values[index].value, isFromDict: false, isPresented: $showEditView)
					case .string:
						PlistStringView(newString: $values[index].value, isFromDict: false, isPresented: $showEditView)
					case .array:
						PlistArrayView(newArray: $values[index].value, isFromDict: false, isPresented: $showEditView)
					case .dict:
						PlistDictView(newDict: $values[index].value, isFromDict: false, isPresented: $showEditView)
					case .data:
						PlistDataView(newData: $values[index].value, isFromDict: false, isPresented: $showEditView)
					case .date:
						PlistDateView(newDate: $values[index].value, isFromDict: false, isPresented: $showEditView)
					case .unknown:
						PlistLView(isPresented: $showEditView)
					}
				})
			}
		}
		.onAppear {
			values = newArray as! [PlistArray]
		}
	}
}
