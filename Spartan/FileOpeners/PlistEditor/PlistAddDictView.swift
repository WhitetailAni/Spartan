//
//  PlistAddView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistAddDictView: View {
	
	@Binding var plistDict: [PlistKey]
	@Binding var isPresented: Bool
	
	let keyTypes = ["Boolean", "Integer", "String", "Array", "Dictionary", "Data"]
	@State var newKeyName = ""
	@State var selectedKeyType = "Boolean"
	
	let null = false
	
	var body: some View {
		VStack {
			Picker(NSLocalizedString("PLIST_KEY", comment: "A Walk Down Strawberry Lane"), selection: $selectedKeyType) {
				ForEach(keyTypes, id: \.self) { keyType in
					Text(keyType)
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 35)
						}
				}
			}
			
			TextField(NSLocalizedString("PLIST_DATA", comment: "Still Alive"), text: $newKeyName)
			
			Button(action: {
				switch selectedKeyType {
				case "Boolean":
					plistDict.append(PlistKey(key: newKeyName, value: false, type: .bool))
				case "Integer":
					plistDict.append(PlistKey(key: newKeyName, value: 0, type: .int))
				case "String":
					plistDict.append(PlistKey(key: newKeyName, value: "", type: .string))
				case "Array":
					let array: [Any] = []
					plistDict.append(PlistKey(key: newKeyName, value: array, type: .array))
				case "Dictionary":
					let dict: [String: Any] = [:]
					plistDict.append(PlistKey(key: newKeyName, value: dict, type: .dict))
				case "Data":
					plistDict.append(PlistKey(key: newKeyName, value: Data(), type: .data))
				default:
					nop()
				}
				isPresented = false
			}) {
				Text(LocalizedString("CONFIRM"))
			}
		}
	}
}
