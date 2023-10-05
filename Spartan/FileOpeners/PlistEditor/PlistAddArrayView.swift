//
//  PlistAddArrayView.swift
//  Spartan
//
//  Created by RealKGB on 8/22/23.
//

import SwiftUI

struct PlistAddArrayView: View {
	
	@Binding var plistArray: [Any]
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
					plistArray.append(false)
				case "Integer":
					plistArray.append(0)
				case "String":
					plistArray.append("")
				case "Array":
					let array: [Any] = []
					plistArray.append(array)
				case "Dictionary":
					let dict: [String: Any] = [:]
					plistArray.append(dict)
				case "Data":
					plistArray.append(Data())
				case "Date":
					plistArray.append(Date())
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
