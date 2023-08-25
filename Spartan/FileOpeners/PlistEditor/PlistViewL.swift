//
//  PlistViewL.swift
//  Spartan
//
//  Created by RealKGB on 8/22/23.
//

import SwiftUI

struct PlistLView: View {
	@Binding var isPresented: Bool

	var body: some View {
		Text("Why are you using funky ass plist key types that no one in their right mind should use, *especially* on an Apple TV??")
		Text("Stop doing that")
			.onAppear {
				print("The app will close in 5 seconds")
				sleep(5)
				exit(76)
			}
			.onExitCommand {
				isPresented = true
			}
	}
}
