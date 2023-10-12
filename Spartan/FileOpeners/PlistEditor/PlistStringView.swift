//
//  PlistStringView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistStringView: View {
	@Binding var value: String
	@Binding var isPresented: Bool
	
	var body: some View {
		TextField(LocalizedString("PLIST_STRINGDATA"), text: $value)
		
		Button(action: {
			isPresented = false
		}) {
			Text(LocalizedString("CONFIRM"))
		}
	}
}
