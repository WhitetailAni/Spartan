//
//  CreditsView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct CreditsView: View {
    var body: some View {
        Text("Spartan file browser, © 2023 by WhitetailAni")
            .font(.system(size: 40))
            .bold()
        Text("""
        "Hopefully not the only tvOS file browser ever"
        """)
        Text("")
        Text("Credits to:")
        Text("SerenaKit: Inspiration from Santander, a lot of guidance with Swift APIs, helping me with yandere dev moments")
        Text("llsc12: SwiftUI help and advice")
        Text("flowerible: UI design advice")
        Text("ChatGPT: Explaining stuff better than Google™")
    }
}
