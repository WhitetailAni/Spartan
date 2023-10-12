//
//  WebserverView.swift
//  Spartan
//
//  Created by RealKGB on 5/21/23.
//

import SwiftUI
import Foundation
//import GCDWebServer

struct WebServerView: View {
	//@Binding var server: GCDWebUploader
	@State var port = 11111

    var body: some View {
        Text("welcome to web server")
        TextField("enter port", value: $port, formatter: NumberFormatter())
        
        HStack {
            Button(action: {
				//server.start()
            }) {
                Text("start")
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
            Button(action: {
                
            }) {
                Text("stop")
            }
        }
    }
}
