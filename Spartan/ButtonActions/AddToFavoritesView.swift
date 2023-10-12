//
//  AddToFavoritesView.swift
//  Spartan
//
//  Created by RealKGB on 4/7/23.
//  The majority of this document is just strings. All it does is take the [String] containing your favorited files and add a value. Of course since I'm using a String for filepath I have to do cleanup on it... but I'm used to that.
//

import SwiftUI

struct AddToFavoritesView: View {
    
    @State var filePath: String
    @State var displayName: String
    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? ["Documents", "Applications", "UserApplications", "Trash"])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/private/var/mobile/Documents/", "/Applications/", "/private/var/containers/Bundle/Application/", "/private/var/mobile/Media/.Trash/"])
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
            UserDefaults.favorites.set(["/private/var/mobile/Documents/", "/Applications/", "/private/var/containers/Bundle/Application/", "/private/var/mobile/Media/.Trash/"], forKey: "favoritesFilePath")
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
