//
//  PlistBoolView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistBoolView: View {
	@Binding var newBool: Any
	@State var nameOfKey: String = ""
	@State var isFromDict: Bool = false
	@Binding var isPresented: Bool
	
	@State var value: Bool = false

	var body: some View {
		if isFromDict {
			Text(nameOfKey)
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 35)
				}
		}
	
		Button(action: {
			value.toggle()
		}) {
			Image(systemName: newBool as! Bool ? "checkmark.square" : "square")
		}
		
		Button(action: {
			newBool = value
			isPresented = false
		}) {
			Text(LocalizedString("CONFIRM"))
		}
		.onAppear {
			value = newBool as! Bool
		}
	}
}
