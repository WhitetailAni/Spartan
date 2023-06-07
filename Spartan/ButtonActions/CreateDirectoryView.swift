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
    
    @State private var errorMessage: String = ""
    @State private var wasError = false

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
                do {
                    try FileManager.default.createDirectory(atPath: directoryPath + directoryName, withIntermediateDirectories: true, attributes: nil)
                    print("Directory created successfully")
                    isPresented = false
                    directoryName = ""
                } catch {
                    errorMessage = error.localizedDescription
                }
                
                if(!(errorMessage == "")){
                    wasError = true
                }
            }) {
                Text(NSLocalizedString("CONFIRM", comment: "That's why we don't need vacations."))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        }
        .alert(isPresented: $wasError) {
            Alert (
                title: Text(NSLocalizedString("ERROR", comment: "- Hi, Jocks!")),
                message: Text(errorMessage),
                dismissButton: .default(Text(NSLocalizedString("DISMISS", comment: "You guys did great!")))
            )
        }
        .accentColor(.accentColor)
    }
}
