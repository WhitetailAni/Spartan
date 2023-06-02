//
//  AddToFavoritesView.swift
//  Spartan
//
//  Created by RealKGB on 4/7/23.
//

import SwiftUI

struct AddToFavoritesView: View {
    
    @Binding var filePath: String
    @Binding var displayName: String
    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? ["Documents", "Applications", "UserApplications", "Trash"])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/var/mobile/Documents/", "/Applications/", "/var/containers/Bundle/Application/", "/var/mobile/Media/.Trash/"])
    @Binding var showView: Bool

    var body: some View {
        Text(NSLocalizedString("FAVORITESADD", comment: "Saves us millions."))
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
        TextField(NSLocalizedString("FAVORITESADD_DISPLAYNAME", comment: "Can anyone work on the Krelman?"), text: $displayName)
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
        TextField(NSLocalizedString("FAVORITESADD_FILEPATH", comment: "Of course. Most bee jobs are small ones."), text: $filePath, onEditingChanged: { (isEditing) in
            if !isEditing {
                if(!(filePath.hasSuffix("/")) && UserDefaults.settings.bool(forKey: "autoComplete")){
                    filePath = filePath + "/"
                }
            }
        })
        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
        }
        Button(action: {
            favoritesDisplayName.append(displayName)
            favoritesFilePath.append(filePath)
            UserDefaults.favorites.set(["Documents", "Applications", "UserApplications", "Trash"], forKey: "favoritesDisplayName")
            UserDefaults.favorites.set(["/var/mobile/Documents/", "/Applications/", "/var/containers/Bundle/Application/", "/var/mobile/Media/.Trash/"], forKey: "favoritesFilePath")
            UserDefaults.favorites.synchronize()
            showView = false
        }) {
            Text(NSLocalizedString("CONFIRM", comment: "But bees know that every small job, if it's done well, means a lot."))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
    }
}
