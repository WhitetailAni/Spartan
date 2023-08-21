//
//  PlistArrayView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI
import Foundation

struct PlistArrayView: View {
	@Binding var newArray: [Any]
	@State var nameOfKey: String = ""
	@State var isNewView: Bool
	@Binding var isPresented: Bool
	
	@State var showAddView = false

	var body: some View {
		VStack {
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
				if isNewView {
					Button(action: {
						isPresented = false
					}) {
						Image(systemName: "square.and.arrow.down")
					}
				}
			}
			ForEach(newArray.indices, id: \.self) { index in
				Button(action: {
					
				}) {
					
				}
			}
		}
	}
}
