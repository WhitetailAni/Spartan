//
//  FavoritesView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct FavoritesView: View {

    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? ["Trash"])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/var/mobile/Media/.Trash/"])
    @Binding var directory: String
    @Binding var showView: Bool

    var body: some View {
        Text("**Favorites**")
        List(favoritesDisplayName, id: \.self) { favoriteDisplayName in
            Button(action: {
                let selectedString = favoriteDisplayName
                let index = favoritesDisplayName.firstIndex(of: selectedString)
                directory = favoritesFilePath[index ?? 0]
                showView = false
            }) {
                Text(favoriteDisplayName)
            }
        }
        Button(action: {
            print(favoritesDisplayName)
            print(favoritesFilePath)
        }) {
            Text("lel")
        }
    }
}

