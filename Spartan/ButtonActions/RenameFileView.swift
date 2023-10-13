//
//  RenameFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct RenameFileView: View {
    @Binding var fileName: String
    @Binding var newFileName: String
    @Binding var filePath: String
    @Binding var isPresented: Bool
    
    var body: some View {
        Text(NSLocalizedString("RENAME_TITLE", comment: "Boy, quite a bit of pomp..."))
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 60)
            }
        TextField(NSLocalizedString("RENAME_NAME", comment: "under the circumstances."), text: $newFileName)
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
        Button(NSLocalizedString("CONFIRM", comment: "Well, Adam, today we are men.")) {
            RootHelperActs.mv(filePath + fileName, filePath + newFileName)
            isPresented = false
        }
    }
}
