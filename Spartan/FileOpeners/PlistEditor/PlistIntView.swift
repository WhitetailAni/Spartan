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
	@State var isNewView: Bool = false
	@Binding var isPresented: Bool
	
	@State var value: Int = 0

	var body: some View {
		if isNewView {
			Text(nameOfKey)
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 35)
				}
		}
	
		StepperTV(value: $value, isHorizontal: true, onCommit: { })
		
		if isNewView {
			Button(action: {
				newInt = value
				isPresented = false
			}) {
				Text(LocalizedString("CONFIRM"))
			}
		}
		.onAppear {
			value = newInt as! Int
		}
	}
}
