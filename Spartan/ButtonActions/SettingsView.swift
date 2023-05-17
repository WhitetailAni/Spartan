//
//  SettingsView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct SettingsView: View {

    @State private var showView: [Bool] = [Bool](repeating: false, count: 2)
    @State private var descriptiveTitlesPre = UserDefaults.settings.bool(forKey: "descriptiveTitles")
    @State private var descriptiveTimestampsPre = UserDefaults.settings.bool(forKey: "verboseTimestamps")
    @State private var autoCompletePre = UserDefaults.settings.bool(forKey: "autoComplete")
    @State private var logWindowFontSizePre = UserDefaults.settings.integer(forKey: "logWindowFontSize")

    var body: some View {
        Text(NSLocalizedString("SETTINGS", comment: "But choose carefully because you'll stay in the job you pick for the rest of your life."))
            .font(.system(size: 60))
            .bold()
        
        StepperTV(value: $logWindowFontSizePre, isHorizontal: true) {
            UserDefaults.settings.set(logWindowFontSizePre, forKey: "logWindowFontSize")
            UserDefaults.settings.synchronize()
        }
        .padding(5)
        Text(NSLocalizedString("SETTINGS_LOGFONTSIZE", comment: "The same job the rest of your life?"))
                .font(.system(size: 25))
            
        descriptiveThings
        autoCompleteFileExtensions
        
        Button(action: {
            showView[1] = true
        }) {
            Image(systemName: "applepencil")
            Text(NSLocalizedString("APPICON", comment: """
            LET'S GO BABY LOVE THE [[METS]] HIT A HOME RUN BABY
            1987 *CAN* HAPPEN AGAIN
            """))
        }
        
        Button(action: { //info
            showView[0] = true
        }) {
            HStack {
                Image(systemName: "info.circle")
                    .frame(width:50, height:50)
                Text(NSLocalizedString("CREDITS", comment: """
                "What's the difference?"
                """))
            }
        }
        .sheet(isPresented: $showView[0], content: {
            CreditsView()
        })
        .sheet(isPresented: $showView[1], content: {
            IconView()
        })
    }
    
    @ViewBuilder
    var descriptiveThings: some View {
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
    }
    
    @ViewBuilder
    var autoCompleteFileExtensions: some View {
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
    }
}

struct IconView: View {

    @State private var attempt: String = ""
    @State private var progress = false

    var body: some View {
        Text("gm")
        Button(action: {
            UIApplication.shared.setAlternateIconName("NotFound") { error in
                if let error = error {
                    attempt = error.localizedDescription
                } else {
                    attempt = "Success!"
                }
                progress = true
            }
        }) {
            Text("icon")
        }
        .sheet(isPresented: $progress, content: {
            Text(attempt)
        })
    }
}
