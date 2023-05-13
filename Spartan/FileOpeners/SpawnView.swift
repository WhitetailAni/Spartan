//
//  SpawnView.swift
//  Spartan
//
//  Created by RealKGB on 4/18/23.
//

import SwiftUI

struct SpawnView: View {
    @Binding var binaryPath: String
    @Binding var binaryName: String
    
    @State var programArguments: String = ""
    @State var spawnLog: String = ""
    @State var descriptiveTitles = UserDefaults.settings.bool(forKey: "descriptiveTitles")

    var body: some View {
        VStack {
            Text(descriptiveTitles ? binaryPath + binaryName : binaryName)
                .font(.system(size: 40))
                .bold()
                .multilineTextAlignment(.center)
                .padding(-20)
            TextField(NSLocalizedString("HEX_ARGS", comment: "MY ESTEEM CUSTOMER I SEE YOU ARE ATTEMPTING TO DEPLETE MY HP!"), text: $programArguments)
            UIKitTextView(text: $spawnLog)
            Button(action: {
                spawnLog = Spartan.task(launchPath: binaryPath + binaryName, arguments: "") as String
            }) {
                Text(NSLocalizedString("HEX_CONFIRM", comment: "ENJOY THE FIREWORKS, KID!!!!"))
            }
        }
    }
}
