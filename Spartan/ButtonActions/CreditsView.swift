//
//  CreditsView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        Text("Spartan, © 2023 by WhitetailAni")
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
            .font(.system(size: 60))
        Text("""
        "Hopefully not the only tvOS file browser ever"
        """)
        Text("")
        Text("""
        Credits to:
        SerenaKit: Inspiration from Santander, guidance with Swift APIs
        staturnz: Improving yandereDevFileTypes
        llsc12: SwiftUI advice
        flower: UI/UX advice
        ChatGPT: Explaining stuff better than StackOverflow™
        ...and also writing me UIKit
        """)
            .multilineTextAlignment(.center)
    }
}
