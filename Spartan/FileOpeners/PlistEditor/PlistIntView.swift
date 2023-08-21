//
//  PlistIntView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistIntView: View {
	@Binding var newInt: Int
	@State var nameOfKey: String = ""
	@State var isNewView: Bool = false
	@Binding var isPresented: Bool

	var body: some View {
		if isNewView {
			Text(nameOfKey)
		}
	
		StepperTV(value: $newInt, isHorizontal: true, onCommit: { })
		
		if isNewView {
			Button(action: {
				isPresented = false
			}) {
				Text(LocalizedString("CONFIRM"))
			}
		}
	}
}
