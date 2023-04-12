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
    @State private var addToFavoritesShow = false
    @State private var blank: String = ""

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
            addToFavoritesShow = true
        }) {
            Text("Add to Favorites")
        }
        .sheet(isPresented: $addToFavoritesShow){
            AddToFavoritesView(filePath: $blank, displayName: $blank, showView: $addToFavoritesShow)
        }
    }
}
