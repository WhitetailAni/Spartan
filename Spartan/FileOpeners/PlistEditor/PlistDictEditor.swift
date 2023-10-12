//
//  PlistDictEditor.swift
//  Spartan
//
//  Created by RealKGB on 10/12/23.
//  These are created as go-betweens for editors as I was having issues assigning values earlier. This passes through the entire dict/array value
//

import SwiftUI

struct PlistDictEditor: View {
	@Binding var keyToEdit: PlistKey
	@Binding var isPresented: Bool
	
	let keyTypes = ["Boolean", "Integer", "String", "Array", "Dictionary", "Data", "Date"]
	
	@State var selectedKeyType: String

    var body: some View {
        TextField(LocalizedString("PLIST_KEY"), text: $keyToEdit.key)
        Picker(NSLocalizedString("PLIST_KEY", comment: "A Walk Down Strawberry Lane"), selection: Binding(
                get: { self.selectedKeyType },
                set: { value in
                    self.selectedKeyType = value
                    keyToEdit.type = PlistFormatter.stringRepresentationToPlistKeyType(value)
                    PlistFormatter.resetPlistKeyValue(&keyToEdit)
                }
            )) {
			ForEach(keyTypes, id: \.self) { keyType in
				Text(keyType)
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 35)
					}
			}
		}
		
		switch selectedKeyType {
		case "Boolean":
			PlistBoolView(value: Binding<Bool>(get: { keyToEdit.value as? Bool ?? false }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
		case "Integer":
			PlistIntView(value: Binding<Int>(get: { keyToEdit.value as? Int ?? 0 }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
		case "String":
			PlistStringView(value: Binding<String>(get: { keyToEdit.value as? String ?? "" }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
		case "Array":
			PlistArrayView(values: Binding<[PlistValue]>(get: { keyToEdit.value as? [PlistValue] ?? [] }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
		case "Dictionary":
			PlistDictView(values: Binding<[PlistKey]>(get: { keyToEdit.value as? [PlistKey] ?? [] }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
		case "Data":
			PlistDataView(value: Binding<Data>(get: { keyToEdit.value as? Data ?? withUnsafeBytes(of: &keyToEdit.value) { Data($0) } }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
		case "Date":
			PlistDateView(value: Binding<Date>(get: { keyToEdit.value as? Date ?? Date() }, set: { value in
				keyToEdit.value = value
			}), isPresented: $isPresented)
		default:
			null()
		}
    }
}
