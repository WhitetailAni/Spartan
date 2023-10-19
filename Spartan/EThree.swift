//
//  EThree.swift
//  Spartan
//
//  Created by RealKGB on 4/23/23.
//

import SwiftUI
import CommonCrypto

struct EThree: View {

    @Binding var directory: String
    @Binding var files: [String]
    @Binding var multiSelectFiles: [String]
    @Binding var fileWasSelected: [Bool]
    @Binding var showSubView: [Bool]

    @State private var EList: [Int] = [0,0,0,0]
    @State private var show = false

    var body: some View {
        HStack {
            ForEach(0..<4, id: \.self) { index in
                StepperTV(value: $EList[index], isHorizontal: false) {
                    if(calculateSHA384Hash(value: ListToInt(list: EList))! == "c830ed4b587fef666dcc43461afe5e1d9d56d2e42f619608635a016cfda268284c0bf40d94cb216a3b91ebbea17f5a19") {
                        show = true //i know what it is now
                    }
                }
            }
            .onAppear {
                EList = [0,0,0,0]
            }
        }
        .sheet(isPresented: $show, content: {
            EThreePro(directory: $directory, files: $files, multiSelectFiles: $multiSelectFiles, fileWasSelected: $fileWasSelected, showSubView: $showSubView)
        })
    }
    
    func ListToInt(list: [Int]) -> Int {
        let int = list.reduce(0) { result, number in
            result * 10 + number
        }
        return int
    }
    
    func calculateSHA384Hash(value: Int) -> String? {
        var context = CC_SHA512_CTX()
        guard let data = "\(value)".data(using: .utf8) else { return nil }
        
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Bool in
            guard let pointer = bytes.baseAddress?.assumingMemoryBound(to: UInt8.self) else { return false }
            CC_SHA384_Init(&context)
            CC_SHA384_Update(&context, pointer, CC_LONG(data.count))
            return true
        }
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA384_DIGEST_LENGTH))
        CC_SHA384_Final(&digest, &context)
        
        let hashString = digest.map { String(format: "%02hhx", $0) }.joined()
        return hashString
    }
}

struct EThreePro: View {
    
    @Binding var directory: String
    @Binding var files: [String]
    @Binding var multiSelectFiles: [String]
    @Binding var fileWasSelected: [Bool]
    @Binding var showSubView: [Bool]
    
    @State var buttonWidth: CGFloat = 0
    @State var buttonHeight: CGFloat = 0
    
    @State private var deviceInfo: [String] = []
    @State private var deviceInfoShow = false
    
    let paddingInt: CGFloat = -7
    let opacityInt: CGFloat = 1.0
    
    var body: some View {
    
        Text("Welcome to Milliways")
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 69)
            }
            .font(.system(size: 69))
            .padding(paddingInt)
            .opacity(opacityInt)
            .onAppear {
                let propertyKeys = ["name", "model", "localizedModel", "systemName", "systemVersion", "identifierForVendor"]

                for key in propertyKeys {
                    switch key {
                    case "name":
                        deviceInfo.append(UIDevice.current.name)
                    case "model":
                        deviceInfo.append(UIDevice.current.model)
                    case "localizedModel":
                        deviceInfo.append(UIDevice.current.localizedModel)
                    case "systemName":
                        deviceInfo.append(UIDevice.current.systemName)
                    case "systemVersion":
                        deviceInfo.append(UIDevice.current.systemVersion)
                    case "identifierForVendor":
                        deviceInfo.append(UIDevice.current.identifierForVendor?.uuidString ?? "unknown")
                    default:
                        break
                    }
                }
                
                if UIScreen.main.nativeBounds.height == 2160 {
                    buttonWidth = 1000
                    buttonHeight = 60
                } else if UIScreen.main.nativeBounds.height == 1080 {
                    buttonWidth = 500
                    buttonHeight = 30
                }
            }
        
        Button(action: {
            deviceInfoShow = true
        }) {
            Text("Show Device Info")
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        .sheet(isPresented: $deviceInfoShow, content: {
            EEEE(deviceInfo: $deviceInfo, buttonWidth: $buttonWidth, buttonHeight: $buttonHeight)
        })
        
        
        Button(action: {
            print("What is the answer to Life, the Universe, and Everything?")
        }) {
            Text("42")
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(10)
        .opacity(opacityInt)
        
        firstLaunch
    }
    
    @ViewBuilder
    var firstLaunch: some View {
        Button(action: {
            print(UserDefaults.settings.bool(forKey: "haveLaunchedBefore"))
        }) {
            Text("Print the launch state")
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        Button(action: {
            UserDefaults.settings.set(false, forKey: "haveLaunchedBefore")
        }) {
            Text("Enable first launch")
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        Button(action: {
            UserDefaults.settings.set(true, forKey: "haveLaunchedBefore")
        }) {
            Text("Disable first launch")
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(paddingInt)
        .opacity(opacityInt)
    }
}

struct EEEE: View {

    @Binding var deviceInfo: [String]
    @Binding var buttonWidth: CGFloat
    @Binding var buttonHeight: CGFloat
    
    var body: some View {
        Text("Don't worry, sir. I'll be very humane.")
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 60)
            }
            .font(.system(size: 60))
        ForEach(deviceInfo.indices, id: \.self) { index in
            if(index == 0) {
                Button(action: {
                    print(deviceInfo[index])
                }) {
                    Text("Device Name: \(deviceInfo[index])")
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
            } else if(index == 1) {
                Button(action: {
                    print(deviceInfo[index])
                }) {
                    Text("Device Type: \(deviceInfo[index])")
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
            } else if(index == 3) {
                Button(action: {
                    print("\(deviceInfo[index]) \(deviceInfo[4])")
                }) {
                    Text("Software Version: \(deviceInfo[index]) \(deviceInfo[4])")
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
            } else if(index == 5) {
                Button(action: {
                    print(deviceInfo[index])
                }) {
                    Text("Device ID: \(deviceInfo[index])")
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
            }
        }
    }
}
