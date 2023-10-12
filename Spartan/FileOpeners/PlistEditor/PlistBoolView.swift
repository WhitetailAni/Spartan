//
//  PlistBoolView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistBoolView: View {
	@Binding var value: Bool
	@Binding var isPresented: Bool

	var body: some View {
		Button(action: {
			value.toggle()
		}) {
			Image(systemName: value ? "checkmark.square" : "square")
		}
		
		Button(action: {
			isPresented = false
		}) {
			Text(LocalizedString("CONFIRM"))
		}
	}
}
