//
//  SettingsView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI
import Foundation
import Combine

//settings vars

struct SettingsView: View {

    @State private var infoShow = false
    @State var descriptiveTitlesState = false
    @EnvironmentObject var settingsVariables: SettingsVariables

    var body: some View {
        Text("Settings")
            .font(.system(size: 40))
            .bold()
        Button(action: {
            settingsVariables.descriptiveTitles.toggle()
        }) {
            Text("Descriptive Titles")
            Image(systemName: settingsVariables.descriptiveTitles ? "checkmark.square" : "square")
        }
        Text("If enabled, shows the full filepath to a given file. Otherwise just the name of the file is shown.")
            .font(.system(size: 25))
        
        Button(action: { //info
            infoShow = true
        }) {
            Image(systemName: "info.circle")
                .frame(width:50, height:50)
        }
        
        .sheet(isPresented: $infoShow, content: {
            CreditsView()
        })
    }
}
