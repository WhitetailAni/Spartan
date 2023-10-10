//
//  PlistDictView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistDictView: View {
	@Binding var newDict: Any
	@State var nameOfKey: String = ""
	@State var isFromDict: Bool
	@Binding var isPresented: Bool
	
	@State var addItemToDict = false
	@State var isEditing = false
	@State var values: [PlistKey] = []

	var body: some View {
		VStack {
			HStack {
				Button(action: {
					addItemToDict = true
				}) {
					Image(systemName: "plus")
				}
				.sheet(isPresented: $addItemToDict, content: {
					PlistAddDictView(plistDict: $values, isPresented: $addItemToDict)
				})
				
				Spacer()
				if isFromDict {
					Text(nameOfKey)
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 35)
						}
				}
				Spacer()
				
				Button(action: {
					newDict = values
					isPresented = false
				}) {
					Image(systemName: "checkmark")
				}
				.onAppear {
					values = newDict as! [PlistKey]
				}
			}
			
			List(values.indices, id: \.self) { index in
				Button(action: {
					if values[index].type == .bool {
						values[index].value = !(values[index].value as! Bool)
					} else {
						isEditing = true
					}
				}) {
					if values[index].type == .bool {
						Image(systemName: values[index].value as! Bool ? "checkmark.square" : "square")
					}
					Text(PlistFormatter.formatPlistKeyForDisplay(values[index]))
				}
				.sheet(isPresented: $isEditing, content: {
					switch values[index].type {
					case .bool:
						null()
					case .int:
						PlistIntView(newInt: $values[index].value, isFromDict: true, isPresented: $isEditing)
					case .string:
						PlistStringView(newString: $values[index].value, isFromDict: true, isPresented: $isEditing)
					case .array:
						PlistArrayView(newArray: $values[index].value, isFromDict: true, isPresented: $isEditing)
					case .dict:
						PlistDictView(newDict: $values[index].value, isFromDict: true, isPresented: $isEditing)
					case .data:
						PlistDataView(newData: $values[index].value, isFromDict: true, isPresented: $isEditing)
					case .date:
						PlistDateView(newDate: $values[index].value, isFromDict: true, isPresented: $isEditing)
					case .unknown:
						PlistLView(isPresented: $isEditing)
					}
				})
			}
		}
	}
}
