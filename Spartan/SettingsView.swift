//
//  SettingsView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct SettingsView: View {

    @State private var infoShow = false

    var body: some View {
        Text("Settings")
            .font(.system(size: 40))
            .bold()
        Button(action: {
            print("e")
        }) {
            Text("a thing")
        }
        
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

