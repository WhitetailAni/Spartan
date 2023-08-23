//
//  PlistIntView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistIntView: View {
	@Binding var newInt: Any
	@State var nameOfKey: String = ""
	@State var isFromDict: Bool
	@Binding var isPresented: Bool
	
	@State var value: Int = 0

	var body: some View {
		if isFromDict {
			Text(nameOfKey)
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 35)
				}
		}
	
		StepperTV(value: $value, isHorizontal: true, onCommit: { })
			.onAppear {
				value = newInt as! Int
			}
		
		Button(action: {
			newInt = value
			isPresented = false
		}) {
			Text(LocalizedString("CONFIRM"))
		}
	}
}
