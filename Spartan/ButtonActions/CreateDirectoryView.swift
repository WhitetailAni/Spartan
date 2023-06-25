//
//  CreateDirectoryView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct CreateDirectoryView: View {
    @State var directoryName: String = ""
    @Binding var directoryPath: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text(NSLocalizedString("DIRTOUCH_TITLE", comment: "I guess he could have just gotten out of the way."))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            TextField(NSLocalizedString("DIRTOUCH_NAME", comment: "I love this incorporating an amusement park into our day."), text: $directoryName)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                
            Button(action: {
                spawn(command: helperPath, args: ["td", directoryPath + directoryName], env: [], root: true)
                isPresented = false
                directoryName = ""
            }) {
                Text(NSLocalizedString("CONFIRM", comment: "That's why we don't need vacations."))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        }
        .accentColor(.accentColor)
    }
}
