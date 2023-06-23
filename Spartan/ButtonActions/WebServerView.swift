//
//  WebserverView.swift
//  Spartan
//
//  Created by RealKGB on 5/21/23.
//

import SwiftUI

struct WebServerView: View {
 
    @State var webdavLog: String = ""
    @State var port: UInt16 = 11111
    @State var isTapped = false

    var body: some View {
        Text("welcome to web server")
        TextField("enter port", value: $port, formatter: NumberFormatter())
        
        HStack {
            Button(action: {

            }) {
                Text("start")
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .disabled(isTapped)
            }
            Button(action: {
                
            }) {
                Text("stop")
            }
        }
        UIKitTextView(text: $webdavLog, fontSize: CGFloat(UserDefaults.settings.integer(forKey: "logWindowFontSize")), isTapped: $isTapped)
            .onExitCommand {
                isTapped = false
            }
    }
}
