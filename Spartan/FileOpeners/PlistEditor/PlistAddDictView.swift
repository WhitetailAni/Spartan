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
	
	let keyTypes = ["Boolean", "Integer", "String", "Array", "Dictionary", "Data", "Date"]
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
			
			TextField(NSLocalizedString("PLIST_KEY", comment: "Still Alive"), text: $newKeyName)
			
			Button(action: {
				switch selectedKeyType {
				case "Boolean":
					plistDict.append(PlistKey(key: newKeyName, value: false, type: .bool))
				case "Integer":
					plistDict.append(PlistKey(key: newKeyName, value: 0, type: .int))
				case "String":
					plistDict.append(PlistKey(key: newKeyName, value: "A", type: .string))
				case "Array":
					let array: [PlistArray] = []
					plistDict.append(PlistKey(key: newKeyName, value: array, type: .array))
				case "Dictionary":
					let dict: [PlistKey] = []
					plistDict.append(PlistKey(key: newKeyName, value: dict, type: .dict))
				case "Data":
					plistDict.append(PlistKey(key: newKeyName, value: Data([UInt8(0), UInt8(0), UInt8(0), UInt8(0)]), type: .data))
				case "Date":
					plistDict.append(PlistKey(key: newKeyName, value: Date(), type: .date))
				default:
					nop()
				}
				plistDict.sort { $0.key < $1.key }
				isPresented = false
			}) {
				Text(LocalizedString("CONFIRM"))
			}
		}
	}
}
