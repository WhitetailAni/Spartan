//
//  PlistIntView.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI

struct PlistIntView: View {
	@Binding var value: Int
	@Binding var isPresented: Bool

	var body: some View {
		StepperTV(value: $value, isHorizontal: true, onCommit: { })
		
		Button(action: {
			isPresented = false
		}) {
			Text(LocalizedString("CONFIRM"))
		}
	}
}
