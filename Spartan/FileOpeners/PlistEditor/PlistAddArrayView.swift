//
//  PlistAddArrayView.swift
//  Spartan
//
//  Created by RealKGB on 8/22/23.
//

import SwiftUI

struct PlistAddArrayView: View {
	
	@Binding var plistArray: [PlistArray]
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
					plistArray.append(PlistArray(value: false, type: .bool))
				case "Integer":
					plistArray.append(PlistArray(value: 0, type: .int))
				case "String":
					plistArray.append(PlistArray(value: "", type: .string))
				case "Array":
					let array: [PlistArray] = []
					plistArray.append(PlistArray(value: array, type: .array))
				case "Dictionary":
					let dict: [PlistKey] = []
					plistArray.append(PlistArray(value: dict, type: .dict))
				case "Data":
					plistArray.append(PlistArray(value: Data(), type: .data))
				case "Date":
					plistArray.append(PlistArray(value: Date(), type: .date))
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
