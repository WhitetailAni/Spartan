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
    
    @State private var errorMessage: String = ""
    @State private var wasError = false

    var body: some View {
        VStack {
            Text(NSLocalizedString("SYMTOUCH_TITLE", comment: "- Hey, those are Pollen Jocks!"))
                .bold()
            TextField(NSLocalizedString("SYMTOUCH_NAME", comment: "- Wow."), text: $symlinkName)
            TextField(NSLocalizedString("SYMTOUCH_DEST", comment: "I've never seen them this close."), text: $symlinkDest, onEditingChanged: { (isEditing) in
                    if !isEditing {
                        if(symlinkName.hasSuffix("/")) && UserDefaults.settings.bool(forKey: "autoComplete"){
                            symlinkName = String(symlinkName.dropLast())
                        }
                    }
                }
            )
            Button(NSLocalizedString("CONFIRM", comment: "They know what it's like outside the hive.")) {
                do {
                    try FileManager.default.createSymbolicLink(atPath: symlinkPath + symlinkName, withDestinationPath: symlinkDest)
                    print("Symlink created successfully")
                    isPresented = false
                    symlinkName = ""
                } catch {
                    errorMessage = error.localizedDescription
                    print(errorMessage)
                }
                
                if(!(errorMessage == "")){
                    wasError = true
                }
            }
        }
        .alert(isPresented: $wasError) {
            Alert (
                title: Text(NSLocalizedString("ERROR", comment: "Yeah, but some don't come back.")),
                message: Text(errorMessage),
                dismissButton: .default(Text(NSLocalizedString("DISMISS", comment: "- Hey, Jocks!")))
            )
        }
        .accentColor(.accentColor)
    }
}
