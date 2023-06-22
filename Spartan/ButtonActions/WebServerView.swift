//
//  WebserverView.swift
//  Spartan
//
//  Created by RealKGB on 5/21/23.
//

import SwiftUI
import Swifter

struct WebServerView: View {

    @Binding var inputServer: HttpServer
    @State var webdavLog: String = ""
    @State var port: UInt16 = 11111
    @State var isTapped = false

    var body: some View {
        Text("welcome to web server")
        TextField("enter port", value: $port, formatter: NumberFormatter())
        Button(action: {
            webdavLog += "\nwhy, this does nothing"
        }) {
            Text("start")
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                .disabled(isTapped)
        }
        UIKitTextView(text: $webdavLog, fontSize: CGFloat(UserDefaults.settings.integer(forKey: "logWindowFontSize")), isTapped: $isTapped)
            .onAppear {
                serverStart(server: inputServer)
            }
            .onExitCommand {
                isTapped = false
            }
    }
    
    func serverStart(server: HttpServer) {
        server["/hello"] = { request in
            .ok(.htmlBody("welcome to web server spartan edition"))
        }
        do {
            try server.start(port)
            webdavLog = "try 10.0.0.45:\(port)"
        } catch {
            webdavLog = error.localizedDescription
        }
    }
}
