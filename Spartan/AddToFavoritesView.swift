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
        TextField("Enter the name that will display in Favorites", text: $displayName)
        TextField("Enter the file path for the item you wish to add", text: $filePath, onEditingChanged: { (isEditing) in
            if !isEditing {
                if(!(filePath.hasSuffix("/")) && UserDefaults.settings.bool(forKey: "autoComplete")){
                    filePath = filePath + "/"
                }
            }
        })
        Button(action: {
            favoritesDisplayName.append(displayName)
            favoritesFilePath.append(filePath)
            UserDefaults.favorites.set(["Documents", "Applications", "UserApplications", "Trash"], forKey: "favoritesDisplayName")
            UserDefaults.favorites.set(["/var/mobile/Documents/", "/Applications/", "/var/containers/Bundle/Application/", "/var/mobile/Media/.Trash/"], forKey: "favoritesFilePath")
            UserDefaults.favorites.synchronize()
            showView = false
        }) {
            Text("Confirm")
        }
    }
}
