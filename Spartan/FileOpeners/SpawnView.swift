//
//  SpawnView.swift
//  Spartan
//
//  Created by RealKGB on 4/18/23.
//

import SwiftUI

struct SpawnView: View {
    @Binding var filePath: String
    @Binding var fileName: String
    @State var programArguments: String = ""
    @State var envVars: String = ""
    @State var spawnAsRoot = false
    @State var stdLog: String = ""
    
    @State var isTapped = false
    
    var body: some View {
        VStack {
            Text(UserDefaults.settings.bool(forKey: "descriptiveTitles") ? filePath + fileName : fileName)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                .font(.system(size: 40))
                .multilineTextAlignment(.center)
                .disabled(isTapped)
                
            HStack {
                TextField(NSLocalizedString("SPAWN_ARGS", comment: "MY ESTEEM CUSTOMER I SEE YOU ARE ATTEMPTING TO DEPLETE MY HP!"), text: $programArguments)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .disabled(isTapped)
                TextField(NSLocalizedString("SPAWN_ENV", comment: "KRIS! ISN'T THIS [Body] JUST [Heaven]LY!?"), text: $envVars)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .disabled(isTapped)
            }
            
            UIKitTextView(text: $stdLog, fontSize: CGFloat(UserDefaults.settings.integer(forKey: "logWindowFontSize")), isTapped: $isTapped)
                .onExitCommand {
                    isTapped = false
                }
            
            HStack {
                HStack {
                    Spacer()
                    Button(action: {
                        let args = programArguments.split(separator: " ").map(String.init)
                        let env = envVars.split(separator: " ").map(String.init)
                        stdLog = spawn(command: filePath + fileName, args: args, env: env, root: false)
                    }) {
                        Text(NSLocalizedString("SPAWN_CONFIRM", comment: "ENJOY THE FIR3WORKS, KID!!!!"))
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .disabled(isTapped)
                }
                
                HStack {
                    Button(action: {
                        let args = programArguments.split(separator: " ").map(String.init)
                        let env = envVars.split(separator: " ").map(String.init)
                        stdLog = spawn(command: filePath + fileName, args: args, env: env, root: true)
                    }) {
                        Text(NSLocalizedString("SPAWN_ROOTCONFIRM", comment: "ENJOY THE FIR3WORKS, KID!!!!"))
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .disabled(isTapped)
                    Spacer()
                }
            }
        }
    }
}
