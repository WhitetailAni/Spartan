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
	
	@State var indexToEdit = 0
	@State var showEditView = false
	@State var showAddView = false

	var body: some View {
		VStack {
			if isFromDict {
				Text(nameOfKey)
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 35)
					}
			}
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
				Text(nameOfKey)
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 40)
					}
					.font(.system(size: 40))
					.multilineTextAlignment(.center)
					.padding(-10)
					.focusable(true)
					
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
						indexToEdit = index
						showEditView = true
					}
				}) {
					if values[index].value is Bool {
						Image(systemName: values[index].value as! Bool ? "checkmark.square" : "square")
					}
					Text("\(PlistFormatter.formatAnyVarForDisplay(values[index].value)) (\(PlistFormatter.plistKeyTypeToString(values[index].type))")
				}
			}
		}
		.sheet(isPresented: $showEditView, content: {
			switch values[indexToEdit].type {
			case .bool:
				Text("All I need is a little neurotoxin.")
			case .int:
				PlistIntView(newInt: $values[indexToEdit].value, isFromDict: false, isPresented: $showEditView)
			case .string:
				PlistStringView(newString: $values[indexToEdit].value, isFromDict: false, isPresented: $showEditView)
			case .array:
				PlistArrayView(newArray: $values[indexToEdit].value, isFromDict: false, isPresented: $showEditView)
			case .dict:
				PlistDictView(newDict: $values[indexToEdit].value, isFromDict: false, isPresented: $showEditView)
			case .data:
				PlistDataView(newData: $values[indexToEdit].value, isFromDict: false, isPresented: $showEditView)
			case .date:
				PlistDateView(newDate: $values[indexToEdit].value, isFromDict: false, isPresented: $showEditView)
			case .unknown:
				PlistLView(isPresented: $showEditView)
			}
		})
		.onAppear {
			values = newArray as! [PlistArray]
		}
	}
}
