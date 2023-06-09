//
//  CarView.swift
//  Spartan
//
//  Created by RealKGB on 5/30/23.
//

import SwiftUI

struct CarView: View {
    @Binding var filePath: String
    @Binding var fileName: String

    var body: some View {
        Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 60)
            }
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
        List(["E"] ?? ["An error occurred while trying to read the file"], id: \.self) { passenger in
            Text(passenger)
        }
        .onAppear {
            
        }
    }
}
