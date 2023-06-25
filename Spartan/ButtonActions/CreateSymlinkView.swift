//
//  CreateSymlinkView.swift
//  Spartan
//
//  Created by RealKGB on 4/25/23.
//

import SwiftUI

struct CreateSymlinkView: View {
    @Binding var symlinkPath: String
    @State private var symlinkName: String = ""
    @State private var symlinkDest: String = ""
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text(NSLocalizedString("SYMTOUCH_TITLE", comment: "- Hey, those are Pollen Jocks!"))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            TextField(NSLocalizedString("SYMTOUCH_NAME", comment: "- Wow."), text: $symlinkName)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            TextField(NSLocalizedString("SYMTOUCH_DEST", comment: "I've never seen them this close."), text: $symlinkDest, onEditingChanged: { (isEditing) in
                    if !isEditing {
                        if(symlinkName.hasSuffix("/")) && UserDefaults.settings.bool(forKey: "autoComplete"){
                            symlinkName = String(symlinkName.dropLast())
                        }
                    }
                }
            )
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
            
            Button(action: {
                spawn(command: helperPath, args: ["ts", symlinkPath + symlinkName, symlinkDest], env: [], root: true)
                isPresented = false
                symlinkName = ""
            }) {
                Text(NSLocalizedString("CONFIRM", comment: "They know what it's like outside the hive."))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        }
        .accentColor(.accentColor)
    }
}
