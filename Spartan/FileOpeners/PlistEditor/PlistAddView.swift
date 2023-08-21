//
//  PlistAddView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistAddView: View {
	
	@Binding var plistDict: [PlistKey]
	
	@State var newKeyName = ""
	@State var selectedKeyType = "Boolean"
	@State var newBool = false
	@State var newInt = 0
	@State var newString = ""
	@State var newArray: [Any] = []
	@State var newDict: [String: Any] = [:]
	@State var newData = Data()
	//easier than having a single Any and casting it all the time.
	
	let garbage = false
	
	let keyTypes = ["Boolean", "Integer", "String", "Array", "Dictionary", "Data"]
	
	var body: some View {
		Text("gm")
		VStack {
			Picker("so many views", selection: $selectedKeyType) {
				ForEach(keyTypes, id: \.self) { keyType in
					Text(keyType)
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 35)
						}
				}
			}
			switch selectedKeyType {
			case "Boolean":
				PlistBoolView(newBool: newBool, isPresented: false)
			case "Integer":
				PlistIntView(newInt: newInt, isPresented: false)
			case "String":
				PlistStringView(newString: newString, isPresented: false)
			case "Array":
				
			case "Dictionary":
			
			case "Data":
				
			default:
				Text("I pray for your soul if this ever appears")
			}
			
			Button(action: {
			
			}) {
				Text(LocalizedString("CONFIRM"))
			}
		}
	}
}
