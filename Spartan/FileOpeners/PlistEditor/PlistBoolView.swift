//
//  PlistBoolView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistBoolView: View {
	@Binding var newBool: Bool
	@State var isNewView: Bool = false
	@State var nameOfKey: String = ""
	@Binding var isPresented: Bool

	var body: some View {
		if isNewView {
			Text(nameOfKey)
		}
	
		Button(action: {
			newBool.toggle()
		}) {
			Image(systemName: newBool ? "checkmark.square" : "square")
		}
		
		if isNewView {
			Button(action: {
				isPresented = false
			}) {
				Text(LocalizedString("CONFIRM"))
			}
		}
	}
}
