//
//  PlistStringView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistStringView: View {
	@Binding var newString: Any
	@State var nameOfKey: String = ""
	@State var isFromDict: Bool
	@Binding var isPresented: Bool
	
	@State var value: String = ""
	
	var body: some View {
		if isFromDict {
			Text(nameOfKey)
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 35)
				}
		}
	
		TextField(LocalizedString("PLIST_STRINGDATA"), text: $value)
		
		Button(action: {
			newString = value
			isPresented = false
		}) {
			Text(LocalizedString("CONFIRM"))
		}
		.onAppear {
			value = newString as! String
		}
	}
}
