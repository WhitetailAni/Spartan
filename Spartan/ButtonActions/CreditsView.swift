//
//  CreditsView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct CreditsView: View {
	@State var secret = [false, false]
	@State var creditsTitle = "Spartan, © 2023 by WhitetailAni"

	var body: some View {
		ZStack {
			VStack {
				if secret[0] {
					Text("Spartan, © 2023 by WhitetailAni 🏳️‍⚧️")
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 60)
						}
						.font(.system(size: 60))
				} else {
					Text("Spartan, © 2023 by WhitetailAni")
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 60)
						}
						.font(.system(size: 60))
				}
				Text("""
				"Hopefully not the only tvOS file browser ever"
				""")
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 25)
					}
				Text("")
				Text("""
				Credits to:
				SerenaKit: Inspiration from Santander, PrivateKits, explaining how sandboxes work
				staturnz: Improving yandereDevFileTypes
				llsc12: SwiftUI advice
				flower: UI/UX advice
				ChatGPT: Explaining stuff better than StackOverflow™
				...and also writing me UIKit
				StackOverflow: Working with Data in Swift
				""")
				.multilineTextAlignment(.center)
				.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
					view.scaledFont(name: "BotW Sheikah Regular", size: 25)
				}
			}
			.focusable(true)
			.onPlayPauseCommand {
				withAnimation(.spring) {
					secret[0].toggle()
				}
			}
			.onAppear {
				DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
					withAnimation(.easeIn) {
						secret[1] = true
					}
				}
			}
			VStack {
				Spacer()
				if secret[1] {
					Text("You should try pressing the Play/Pause button")
						.onAppear {
							DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
								withAnimation(.easeIn) {
									secret[1] = false
								}
							}
						}
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 17)
						}
				}
			}
		}
    }
}
