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
    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? ["Trash"])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/var/mobile/Media/.Trash/"])
    @Binding var showView: Bool

    var body: some View {
        TextField("ADD_TO_FAVORITES_VIEW_DISPLAYNAME", text: $displayName)
        TextField("ADD_TO_FAVORITES_VIEW_FILEPATH", text: $filePath)
        Button(action: {
            favoritesDisplayName.append(displayName)
            favoritesFilePath.append(filePath)
            UserDefaults.favorites.set(favoritesDisplayName, forKey: "favoritesDisplayName")
            UserDefaults.favorites.set(favoritesFilePath, forKey: "favoritesFilePath")
            UserDefaults.favorites.synchronize()
            showView = false
        }) {
            Text("Confirm")
        }
    }
}
