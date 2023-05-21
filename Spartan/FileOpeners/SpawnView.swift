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
    @State var envVars: String = ""
    @State var spawnLog: String = ""
    @State var descriptiveTitles = UserDefaults.settings.bool(forKey: "descriptiveTitles")
    var body: some View {
        VStack {
            Text(descriptiveTitles ? binaryPath + binaryName : binaryName)
                .font(.system(size: 40))
                .bold()
                .multilineTextAlignment(.center)
            TextField(NSLocalizedString("SPAWN_ARGS", comment: "MY ESTEEM CUSTOMER I SEE YOU ARE ATTEMPTING TO DEPLETE MY HP!"), text: $programArguments, onCommit: {
            })
            TextField(NSLocalizedString("SPAWN_ENV", comment: "KRIS! ISN'T THIS [Body] JUST [Heaven]LY!?"), text: $envVars, onCommit: {
            })
            UIKitTextView(text: $spawnLog, fontSize: UserDefaults.settings.integer(forKey: "logWindowFontSize"))
            
            Button(action: {
                SwiftTryCatch.try({
                        spawnLog = Spartan.taskSnoop {
                            Spartan.task(launchPath: binaryPath + binaryName, arguments: programArguments, envVars: envVars)
                        }
                    }, catch: { (error) in
                        spawnLog = error.description
                    }
                )
            }) {
                Text(NSLocalizedString("SPAWN_CONFIRM", comment: "ENJOY THE FIR3WORKS, KID!!!!"))
            }
        }
    }
}



