//
//  PlistStringView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistStringView: View {
	@Binding var newString: String
	@State var nameOfKey: String = ""
	@State var isNewView: Bool
	@Binding var isPresented: Bool
	
	var body: some View {
		if isNewView {
			Text(nameOfKey)
		}
	
		TextField(LocalizedString("PLIST_STRINGDATA"), text: $newString)
		
		if isNewView {
			Button(action: {
				isPresented = false
			}) {
				Text(LocalizedString("CONFIRM"))
			}
		}
	}
}
