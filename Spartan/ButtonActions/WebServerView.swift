//
//  WebserverView.swift
//  Spartan
//
//  Created by RealKGB on 5/21/23.
//

import SwiftUI

struct WebServerView: View {

    @State var webdavLog: String = ""
    @State var port: Int = 11111

    var body: some View {
        Text("welcome to web server")
        TextField("enter port", value: $port, formatter: NumberFormatter())
        UIKitTextView(text: $webdavLog, fontSize: UserDefaults.settings.integer(forKey: "logWindowFontSize"))
        Button(action: {
            webdavLog = "I have no idea what I'm doing please send help"
        }) {
            Text("start")
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
    }
}
