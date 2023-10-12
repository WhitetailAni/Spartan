//
//  PlistAddArrayView.swift
//  Spartan
//
//  Created by RealKGB on 8/22/23.
//

import SwiftUI

struct PlistAddArrayView: View {
	
	@Binding var plistValue: [PlistValue]
	@Binding var isPresented: Bool
	
	@State var selectedKeyType = "Boolean"
	let keyTypes = ["Boolean", "Integer", "String", "Array", "Dictionary", "Data", "Date"]
	let null = false
	
	var body: some View {
		VStack {
			Picker(NSLocalizedString("PLIST_KEY", comment: "Resurrections"), selection: $selectedKeyType) {
				ForEach(keyTypes, id: \.self) { keyType in
					Text(keyType)
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 35)
						}
				}
			}
			
			Button(action: {
				switch selectedKeyType {
				case "Boolean":
					plistValue.append(PlistValue(value: false, type: .bool))
				case "Integer":
					plistValue.append(PlistValue(value: 0, type: .int))
				case "String":
					plistValue.append(PlistValue(value: "", type: .string))
				case "Array":
					let array: [PlistValue] = []
					plistValue.append(PlistValue(value: array, type: .array))
				case "Dictionary":
					let dict: [PlistKey] = []
					plistValue.append(PlistValue(value: dict, type: .dict))
				case "Data":
					plistValue.append(PlistValue(value: Data(), type: .data))
				case "Date":
					plistValue.append(PlistValue(value: Date(), type: .date))
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
