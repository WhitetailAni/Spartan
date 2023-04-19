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
    @State private var descriptiveTitlesPre = UserDefaults.settings.bool(forKey: "descriptiveTitles")
    @State private var descriptiveTimestampsPre = UserDefaults.settings.bool(forKey: "verboseTimestamps")
    @State private var autoCompletePre = UserDefaults.settings.bool(forKey: "autoComplete")
    @State private var testShow = false


    var body: some View {
        Text("Settings")
            .font(.system(size: 60))
            .bold()
        
        Button(action: {
            descriptiveTitlesPre.toggle()
            UserDefaults.settings.set(descriptiveTitlesPre, forKey: "descriptiveTitles")
            UserDefaults.settings.synchronize()
        }) {
            Text("Descriptive Titles")
            Image(systemName: descriptiveTitlesPre ? "checkmark.square" : "square")
        }
        Text("If enabled, shows the full filepath to a given file. Otherwise just the name of the file is shown.")
            .font(.system(size: 25))
            
        Button(action: {
            descriptiveTimestampsPre.toggle()
            UserDefaults.settings.set(descriptiveTimestampsPre, forKey: "verboseTimestamps")
            UserDefaults.settings.synchronize()
        }) {
            Text("Verbose Timestamps")
            Image(systemName: descriptiveTimestampsPre ? "checkmark.square" : "square")
        }
        Text("If enabled, displays timestamps as ss.ssssss instead of mm:ss.")
            .font(.system(size: 25))
            
        Button(action: {
            autoCompletePre.toggle()
            UserDefaults.settings.set(autoCompletePre, forKey: "autoComplete")
            UserDefaults.settings.synchronize()
        }) {
            Text("Autocomplete File Extensions")
            Image(systemName: autoCompletePre ? "checkmark.square" : "square")
        }
        Text("""
             If enabled, will automatically add file extensions if you don't add them,
             such as adding "/" when changing directory or ".zip" to archives.
             """)
             .font(.system(size: 25))
             .multilineTextAlignment(.center)
        Text("WARNING: Make sure you type your filepaths **exactly** if you disable this!")
            .font(.system(size: 25))
        
        Button(action: { //info
            infoShow = true
        }) {
            HStack {
                Image(systemName: "info.circle")
                    .frame(width:50, height:50)
                Text("Credits")
            }
        }
        .sheet(isPresented: $infoShow, content: {
            CreditsView()
        })
    }
}
