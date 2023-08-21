//
//  PlistArrayView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI
import Foundation

struct PlistArrayView: View {
	@Binding var newArray: Any
	@State var nameOfKey: String = ""
	@Binding var isPresented: Bool
	@State var isFromDict: Bool
	
	@State var values: [Any] = []
	@State var showAddView = false

	var body: some View {
		VStack {
			if isFromDict {
				Text(nameOfKey)
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 35)
					}
			}
			HStack {
				Button(action: {
					showAddView = true
				}) {
					Image(systemName: "plus")
				}
				Spacer()
				
				Text(nameOfKey)
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 40)
					}
					.font(.system(size: 40))
					.multilineTextAlignment(.center)
					.padding(-10)
					.focusable(true)
					
				Spacer()
				Button(action: {
					newArray = values
					isPresented = false
				}) {
					Image(systemName: "square.and.arrow.down")
				}
			}
			ForEach(values.indices, id: \.self) { index in
				Button(action: {
					
				}) {
					PlistFormatter.formatAnyVarForDisplay(values[index])
				}
			}
		}
		.onAppear {
			values = newArray as! [Any]
		}
	}
}
