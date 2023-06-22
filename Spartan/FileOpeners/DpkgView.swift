//
//  DpkgView.swift
//  Spartan
//
//  Created by RealKGB on 5/12/23.
//

import SwiftUI
import Foundation

struct DpkgView: View {
    
    @Binding var debPath: String
    @Binding var debName: String
    @Binding var isPresented: Bool
    @Binding var isRootless: Bool
    
    @State var dpkgLog: String = ""
    @State var dpkgPath: String = ""
    
    @State var isExtracting = false
    @State var extractToCurrentDir = true
    @State var extractDest: String = ""
    
    @State var isTapped = false
    
    let fileManager = FileManager.default
    let env = [""]

    var body: some View {
        //if(0 == 1) {
        if !(fileManager.fileExists(atPath: "/usr/bin/dpkg/") || fileManager.fileExists(atPath: "/private/var/jb/usr/bin/dpkg/")) {
            Text(NSLocalizedString("ERR_NOJAILBREAK", comment: "GO AHEAD AND [Scream] INTO THE [Receiver]."))
                .font(.system(size: 60))
        } else {
            if !isExtracting {
                VStack {
                    Text(debName)
                        .font(.system(size: 60))
                    
                    UIKitTextView(text: $dpkgLog, fontSize: CGFloat(UserDefaults.settings.integer(forKey: "logWindowFontSize")), isTapped: $isTapped)
                        .onAppear {
                            if(isRootless) {
                                dpkgPath = "/private/var/jb/usr/bin/dpkg"
                            } else {
                                dpkgPath = "/usr/bin/dpkg"
                            }
                        }
                        .onExitCommand {
                            isTapped = false
                        }
                    HStack {
                        Button(action: {
                            let arguments: String = "-i " + debPath + debName
                            let args = arguments.split(separator: " ").map(String.init)
                            spawn(command: dpkgPath, args: args, env: env, root: true)
                        }) {
                            Text(NSLocalizedString("INSTALL", comment: "THERE WILL BE NO MORE [Miracles] NO MORE [Magic]."))
                        }
                        .disabled(isTapped)
                        
                        Button(action: {
                            withAnimation {
                                isExtracting = true
                            }
                        }) {
                            Text(NSLocalizedString("EXTRACT", comment: "YOU MAKE ME [Sick]!"))
                        }
                        .disabled(isTapped)
                        
                        Button(action: {
                            isPresented = false
                        }) {
                            Text(NSLocalizedString("DISMISS", comment: "I REMEMBER WHEN YOU WERE JUST A LOST [Little Sponge]"))
                        }
                        .disabled(isTapped)
                    }
                }
                .transition(.opacity)
            } else {
                VStack {
                    TextField(NSLocalizedString("DEST_PATH", comment: "I GAVE YOU EVERYTHING I HAD! MY LIFE ADVICE!"), text: $extractDest)
                        .disabled(extractToCurrentDir)
                    Button(action: {
                        extractToCurrentDir.toggle()
                    }) {
                        Image(systemName: extractToCurrentDir ? "checkmark.square" : "square")
                    }
                    Button(action: {
                        if(extractToCurrentDir) {
                            extractDest = debPath
                        }
                        let arguments = "-x " + (debPath + debName) + " " + extractDest
                        let args = arguments.split(separator: " ").map(String.init)
                        let logs = spawn(command: dpkgPath + "-deb", args: args, env: env, root: true)
                    }) {
                        Text(NSLocalizedString("EXTRACT", comment: "I GAVE YOU MY [Commemorative Ring] FOR THE PRICE OF [My Favorite Year]!"))
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

struct DpkgBuilderView: View {

    @Binding var debInputDir: String
    @Binding var debInputName: String
    @Binding var isPresented: Bool
    @Binding var isRootless: Bool
    
    @State private var debOutputDir: String = ""
    @State private var debOutputName: String = ""
    @State private var debOutputVars: String = ""
    
    @State private var compressionTypes: [String] = ["xz", "gzip", "bzip2", "lzma", "none"]
    @State private var selectedCompressionType = "xz"
    @State private var dpkgDebLog: String = ""
    @State private var dpkgPath: String = ""
    
    @State var isTapped = false
    
    let fileManager = FileManager.default
    let env = [""]
    
    var body: some View {
        //if(0 == 1) {
        if !(fileManager.fileExists(atPath: "/usr/bin/dpkg/") || fileManager.fileExists(atPath: "/private/var/jb/usr/bin/dpkg/")) {
            Text(NSLocalizedString("ERR_NOJAILBREAK", comment: "AND THIS IS HOW YOU [Repay] ME!? TREATING ME LIKE [DLC]!?"))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 60)
                }
                .font(.system(size: 60))
        } else {
            Text(debInputDir)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                .font(.system(size: 40))
                
            TextField(NSLocalizedString("DPKGDEB_OUTDIR", comment: "NO, I GET IT! IT'S YOU AND THAT [Hochi Mama]!") + NSLocalizedString("OPTIONAL", comment: "YOU'VE BEEN MAKING [Hyperlink Blocked]!"), text: $debOutputDir, onCommit: {
                updateLog()
            })
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
            .disabled(isTapped)
        
            TextField(NSLocalizedString("DPKGDEB_OUTNAME", comment: "I WAS TOO [Trusting] TOO [Honest]") + NSLocalizedString("OPTIONAL", comment: ""), text: $debOutputName, onCommit: {
                print(debOutputName)
                updateLog()
            })
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
            .disabled(isTapped)
        
            Text(NSLocalizedString("DPKGDEB_COMPTYPE", comment: "I SHOULD HAVE KNOWN YOU WOULD HAVE USED MY [Ring] FOR [Evil]..."))
            Picker("E", selection: $selectedCompressionType) {
                ForEach(compressionTypes, id: \.self) { compressionType in
                    Text(compressionType)
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                        }
                }
            }
            .pickerStyle(DefaultPickerStyle())
            .onReceive([selectedCompressionType].publisher, perform: { value in
                updateLog()
            })
            .disabled(isTapped)
            
            UIKitTextView(text: $dpkgDebLog, fontSize: CGFloat(UserDefaults.settings.integer(forKey: "logWindowFontSize")), isTapped: $isTapped)
                .onAppear {
                    updateLog()
                }
                .onExitCommand {
                    isTapped = false
                }
            
            Button(action: {
                updateLog()
                dpkgDebLog += "\n"
                let arguments: String = " -Z " + selectedCompressionType + " -b " + debInputDir + debOutputVars
                let args = arguments.split(separator: " ").map(String.init)
                spawn(command: dpkgPath, args: args, env: env, root: true)
            }) {
                Text(NSLocalizedString("BUILD", comment: "YOU THINK MAKING [Frozen Chicken] WITH YOUR [Side Chick]"))
            }
            .onAppear {
                if(isRootless) {
                    dpkgPath = "/private/var/jb/usr/bin/dpkg-deb"
                } else {
                    dpkgPath = "/usr/bin/dpkg-deb"
                }
            }
            .disabled(isTapped)
        }
    }
    
    func updateLog() {
        debOutputVars = ""
        if(debOutputDir != "") {
            if(!debOutputDir.hasSuffix("/")){
                debOutputDir += "/"
            }
            debOutputVars = debOutputDir
        }
        if(debOutputName != "") {
            debOutputVars += debOutputName
        }
        
        dpkgDebLog = "\(dpkgPath) -Z \(selectedCompressionType) -b \(debInputDir)\(debOutputVars)"
    }
}
