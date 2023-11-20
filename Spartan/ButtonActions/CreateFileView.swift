//
//  CreateFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct CreateFileView: View {
    @State var fileName: String = ""
    @Binding var filePath: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text(NSLocalizedString("TOUCH_TITLE", comment: "Everybody knows, sting someone, you die."))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            TextField(NSLocalizedString("TOUCH_NAME", comment: "Don't waste it on a squirrel."), text: $fileName)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                
            Button(action: {
                RootHelperActs.touch(filePath + fileName)
                fileName = ""
                isPresented = false
            }) {
                Text(NSLocalizedString("CONFIRM", comment: "Such a hothead."))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        }
        .accentColor(.accentColor)
    }
}
