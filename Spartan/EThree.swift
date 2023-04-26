//
//  EThree.swift
//  Spartan
//
//  Created by RealKGB on 4/23/23.
//

import SwiftUI

struct EThree: View {
    
    @Binding var directory: String
    @Binding var files: [String]
    @Binding var multiSelectFiles: [String]
    @Binding var fileWasSelected: [Bool]
    @Binding var showSubView: [Bool]
    
    @State var buttonWidth: CGFloat = 0
    @State var buttonHeight: CGFloat = 0
    
    @State private var deviceInfo: [String] = []
    @State private var deviceInfoShow = false
    
    var yandereDevFileTypeDebugTransfer: ((String) -> Int)? = nil
    //var realFreeSpace: ((Double) -> (Double, String))? = nil
    
    var body: some View {
        let paddingInt: CGFloat = -7
        let opacityInt: CGFloat = 1.0
    
        Text("Welcome to Milliways")
            .font(.system(size: 69))
            .bold()
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
            print(directory)
        }) {
            Text("Print 'directory'")
                .frame(width: buttonWidth, height: buttonHeight)
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        
        Button(action: {
            for file in files {
                print(file, ": ", String(Int((yandereDevFileTypeDebugTransfer?(file))!)), terminator: " ")
                if(Int((yandereDevFileTypeDebugTransfer?(file))!) == 0) {
                    print("directory")
                } else if(Int((yandereDevFileTypeDebugTransfer?(file))!) == 1) {
                    print("audio file")
                } else if(Int((yandereDevFileTypeDebugTransfer?(file))!) == 2) {
                    print("video file")
                } else if(Int((yandereDevFileTypeDebugTransfer?(file))!) == 3) {
                    print("image")
                } else if(Int((yandereDevFileTypeDebugTransfer?(file))!) == 4) {
                    print("text file")
                } else if(Int((yandereDevFileTypeDebugTransfer?(file))!) == 5) {
                    print("plist")
                } else if(Int((yandereDevFileTypeDebugTransfer?(file))!) == 6) {
                    print("archive (currently zip only)")
                } else if(Int((yandereDevFileTypeDebugTransfer?(file))!) == 7) {
                    print("executable")
                } else if(Int((yandereDevFileTypeDebugTransfer?(file))!) == 8) {
                    print("symlink")
                    print("how did we get here?")
                }
            }
        }) {
            Text("Print 'files'")
                .frame(width: buttonWidth, height: buttonHeight)
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        
        Button(action: {
            print("\(multiSelectFiles) \(multiSelectFiles.count)")
        }) {
            Text("Print 'multiSelectFiles'")
                .frame(width: buttonWidth, height: buttonHeight)
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        
        Button(action: {
            print("\(fileWasSelected) \(fileWasSelected.count)")
        }) {
            Text("Print 'fileWasSelected'")
                .frame(width: buttonWidth, height: buttonHeight)
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        
        Button(action: {
            print("\(showSubView) \(showSubView.count)")
        }) {
            Text("Print 'showSubView'")
                .frame(width: buttonWidth, height: buttonHeight)
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        Button(action: {
            deviceInfoShow = true
        }) {
            Text("Show Device Info")
                .frame(width: buttonWidth, height: buttonHeight)
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
        }
        .padding(10)
        .opacity(opacityInt)
    }
}

struct EEEE: View {

    @Binding var deviceInfo: [String]
    @Binding var buttonWidth: CGFloat
    @Binding var buttonHeight: CGFloat
    
    var body: some View {
        Text("Don't worry, sir. I'll be very humane.")
            .font(.system(size: 60))
            .bold()
        ForEach(deviceInfo.indices, id: \.self) { index in
            if(index == 0) {
                Button(action: {
                    print(deviceInfo[index])
                }) {
                    Text("Device Name: \(deviceInfo[index])")
                }
            } else if(index == 1) {
                Button(action: {
                    print(deviceInfo[index])
                }) {
                    Text("Device Type: \(deviceInfo[index])")
                }
            } else if(index == 3) {
                Button(action: {
                    print("\(deviceInfo[index]) \(deviceInfo[4])")
                }) {
                    Text("Software Version: \(deviceInfo[index]) \(deviceInfo[4])")
                }
            } else if(index == 5) {
                Button(action: {
                    print(deviceInfo[index])
                }) {
                    Text("Device ID: \(deviceInfo[index])")
                }
            }
        }
    }
}
