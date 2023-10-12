//
//  PlistArrayEditor.swift
//  Spartan
//
//  Created by RealKGB on 10/12/23.
//

import SwiftUI

struct PlistArrayEditor: View {
	@Binding var keyToEdit: PlistValue
	@Binding var isPresented: Bool
	
	let keyTypes = ["Boolean", "Integer", "String", "Array", "Dictionary", "Data", "Date"]
	
	@State var selectedKeyType = "Boolean"

    var body: some View {
        Picker(NSLocalizedString("PLIST_KEY", comment: "A Walk Down Strawberry Lane"), selection: $selectedKeyType) {
			ForEach(keyTypes, id: \.self) { keyType in
				Text(keyType)
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 35)
					}
			}
		}
		.onAppear {
			selectedKeyType = keyToEdit.type.stringRepresentation()
		}
		
		switch selectedKeyType {
		case "Boolean":
			PlistBoolView(value: Binding<Bool>(get: { keyToEdit.value as! Bool }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
			.onAppear {
				keyToEdit.value = false
				keyToEdit.type = .bool
			}
		case "Integer":
			PlistIntView(value: Binding<Int>(get: { keyToEdit.value as! Int }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
			.onAppear {
				keyToEdit.value = 0
				keyToEdit.type = .int
			}
		case "String":
			PlistStringView(value: Binding<String>(get: { keyToEdit.value as! String }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
			.onAppear {
				keyToEdit.value = ""
				keyToEdit.type = .string
			}
		case "Array":
			PlistArrayView(values: Binding<[PlistValue]>(get: { keyToEdit.value as! [PlistValue] }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
			.onAppear {
				let array: [PlistValue] = []
				keyToEdit.value = array
				keyToEdit.type = .array
			}
		case "Dictionary":
			PlistDictView(values: Binding<[PlistKey]>(get: { keyToEdit.value as! [PlistKey] }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
			.onAppear {
				let dict: [PlistKey] = []
				keyToEdit.value = dict
				keyToEdit.type = .array
			}
		case "Data":
			PlistDataView(value: Binding<Data>(get: { keyToEdit.value as? Data ?? withUnsafeBytes(of: &keyToEdit.value) { Data($0) } /*this gets the raw byte representation of the value, in case Data is summoned as a fallback*/ }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
			.onAppear {
				keyToEdit.value = Data()
				keyToEdit.type = .data
			}
		case "Date":
			PlistDateView(value: Binding<Date>(get: { keyToEdit.value as! Date }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
			.onAppear {
				keyToEdit.value = Date()
				keyToEdit.type = .date
			}
		default:
			null()
		}
    }
}
