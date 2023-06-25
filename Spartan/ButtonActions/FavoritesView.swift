//
//  FavoritesView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct FavoritesView: View {

    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? ["Documents", "Applications", "UserApplications", "Trash"])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/private/var/mobile/Documents/", "/Applications/", "/private/var/containers/Bundle/Application/", "/private/var/mobile/Media/.Trash/"]) //change to app bundle, app data, and group app data if jailed
    @Binding var directory: String
    @Binding var showView: Bool
    @State private var addToFavoritesShow = false
    @State private var blank: String = ""

    var body: some View {
        Text(NSLocalizedString("FAVORITES_TITLE", comment: "- Catches that little strand of honey"))
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
        
        List(favoritesDisplayName.indices, id: \.self) { index in
            Button(action: {
                directory = favoritesFilePath[index]
                showView = false
            }) {
                HStack {
                    if(favoritesDisplayName.firstIndex(of: favoritesDisplayName[index])! < 4){
                        switch favoritesDisplayName.firstIndex(of: favoritesDisplayName[index])! {
                        case 0:
                            Image(systemName: "doc.text")
                        case 1:
                            Image(systemName: "applescript")
                        case 2:
                            Image(systemName: "person.crop.circle")
                        case 3:
                            Image(systemName: "trash")
                        case 4:
                            Image(systemName: "questionmark.square.dashed")
                        default:
                            Image(systemName: "questionmark")
                        }
                    }
                    Text(favoritesDisplayName[index])
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
            }
        }
        
        Button(action: {
            addToFavoritesShow = true
        }) {
            Text(NSLocalizedString("FAVORITESADD", comment: "that hangs after you pour it."))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .sheet(isPresented: $addToFavoritesShow){
            AddToFavoritesView(filePath: directory, displayName: URL(fileURLWithPath: directory).lastPathComponent, showView: $addToFavoritesShow)
        }
    }
}
