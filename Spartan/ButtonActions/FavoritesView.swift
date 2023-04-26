//
//  FavoritesView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct FavoritesView: View {

    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? ["Documents", "Applications", "UserApplications", "Trash"])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/var/mobile/Documents/", "/Applications/", "/var/containers/Bundle/Application/", "/var/mobile/Media/.Trash/"])
    @Binding var directory: String
    @Binding var showView: Bool
    @State private var addToFavoritesShow = false
    @State private var blank: String = ""

    var body: some View {
        Text(NSLocalizedString("FAVORITES_TITLE", comment: "- Catches that little strand of honey"))
            .bold()
        
        List(favoritesDisplayName, id: \.self) { favoriteDisplayName in
            Button(action: {
                let index = favoritesDisplayName.firstIndex(of: favoriteDisplayName) ?? 0
                directory = favoritesFilePath[index]
                showView = false
                print(index)
            }) {
                HStack {
                    if(favoritesDisplayName.firstIndex(of: favoriteDisplayName) ?? 0 < 4){
                        if(favoritesDisplayName.firstIndex(of: favoriteDisplayName) ?? 4 == 0){
                            Image(systemName: "doc.text")
                        } else if (favoritesDisplayName.firstIndex(of: favoriteDisplayName) ?? 4 == 1) {
                            Image(systemName: "applescript")
                        } else if (favoritesDisplayName.firstIndex(of: favoriteDisplayName) ?? 4 == 2) {
                            Image(systemName: "person.crop.circle")
                        } else if (favoritesDisplayName.firstIndex(of: favoriteDisplayName) ?? 4 == 3) {
                            Image(systemName: "trash")
                        } else if (favoritesDisplayName.firstIndex(of: favoriteDisplayName) ?? 4 == 4) {
                            Image(systemName: "questionmark.square.dashed")
                        }
                    }
                    Text(favoriteDisplayName)
                }
            }
        }
        
        Button(action: {
            addToFavoritesShow = true
        }) {
            Text(NSLocalizedString("FAVORITESADD", comment: "that hangs after you pour it."))
        }
        .sheet(isPresented: $addToFavoritesShow){
            AddToFavoritesView(filePath: $blank, displayName: $blank, showView: $addToFavoritesShow)
        }
    }
}
