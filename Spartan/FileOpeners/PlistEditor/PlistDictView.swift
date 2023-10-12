//
//  PlistDictView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistDictView: View {
	@Binding var values: [PlistKey]
	@Binding var isPresented: Bool
	
	@State var addItemToDict = false
	@State var isEditing = false

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
				Text(" ")
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 40)
					}
					.font(.system(size: 40))
				Spacer()
				
				Button(action: {
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
						isEditing = true
					}
				}) {
					HStack {
						if values[index].type == .bool {
							Image(systemName: values[index].value as! Bool ? "checkmark.square" : "square")
						}
						Text(PlistFormatter.formatPlistKeyForDisplay(values[index]))
					}
				}
				.sheet(isPresented: $isEditing, content: {
					PlistDictEditor(keyToEdit: $values[index], isPresented: $isEditing)
				})
			}
		}
	}
}
