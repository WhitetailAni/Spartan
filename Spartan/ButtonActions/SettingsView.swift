//
//  SettingsView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct SettingsView: View {

    @State private var infoShow = false
    @State private var descriptiveTitlesPre = UserDefaults.settings.bool(forKey: "descriptiveTitles")
    @State private var descriptiveTimestampsPre = UserDefaults.settings.bool(forKey: "verboseTimestamps")
    @State private var autoCompletePre = UserDefaults.settings.bool(forKey: "autoComplete")
    @State private var testShow = false


    var body: some View {
        Text(NSLocalizedString("SETTINGS", comment: "But choose carefully because you'll stay in the job you pick for the rest of your life."))
            .font(.system(size: 60))
            .bold()
        
        Button(action: {
            descriptiveTitlesPre.toggle()
            UserDefaults.settings.set(descriptiveTitlesPre, forKey: "descriptiveTitles")
            UserDefaults.settings.synchronize()
        }) {
            Text(NSLocalizedString("SETTINGS_TITLES", comment: "The same job the rest of your life?"))
            Image(systemName: descriptiveTitlesPre ? "checkmark.square" : "square")
        }
        Text(NSLocalizedString("SETTINGS_TITLES_DESC", comment: "I didn't know that."))
            .font(.system(size: 25))
            
        Button(action: {
            descriptiveTimestampsPre.toggle()
            UserDefaults.settings.set(descriptiveTimestampsPre, forKey: "verboseTimestamps")
            UserDefaults.settings.synchronize()
        }) {
            Text(NSLocalizedString("SETTINGS_TIMESTAMPS", comment: "What's the difference?"))
            Image(systemName: descriptiveTimestampsPre ? "checkmark.square" : "square")
        }
        Text(NSLocalizedString("SETTINGS_TIMESTAMPS_DESC", comment: "You'll be happy to know that bees, as a species"))
            .font(.system(size: 25))
            
        Button(action: {
            autoCompletePre.toggle()
            UserDefaults.settings.set(autoCompletePre, forKey: "autoComplete")
            UserDefaults.settings.synchronize()
        }) {
            Text(NSLocalizedString("SETTINGS_AUTOCOMPLETE", comment: "haven't had one day off in 27 million years."))
            Image(systemName: autoCompletePre ? "checkmark.square" : "square")
        }
        Text("""
        \(NSLocalizedString("SETTINGS_AUTOCOMPLETE_DESC_1", comment: "So you'll just work us to death?"))
        \(NSLocalizedString("SETTINGS_AUTOCOMPLETE_DESC_2", comment: "We'll sure try."))
        """)
             .font(.system(size: 25))
             .multilineTextAlignment(.center)
        Text(NSLocalizedString("SETTINGS_AUTOCOMPLETE_WARNING", comment: "Wow! That blew my mind!"))
            .font(.system(size: 25))
        
        Button(action: { //info
            infoShow = true
        }) {
            HStack {
                Image(systemName: "info.circle")
                    .frame(width:50, height:50)
                Text(NSLocalizedString("CREDITS", comment: """
                "What's the difference?"
                """))
            }
        }
        .sheet(isPresented: $infoShow, content: {
            CreditsView()
        })
    }
}
