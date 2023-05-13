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
    
    @State var dpkgLog: String = ""
    
    @State var isExtracting = false
    @State var extractToCurrentDir = true
    @State var extractDest: String = ""

    var body: some View {
        if !(FileManager.default.fileExists(atPath: "/usr/bin/dpkg") || FileManager.default.fileExists(atPath: "/var/jb/usr/bin/dpkg")) {
            Text("You need to be jailbroken to install debs.")
                .font(.system(size: 120))
        } else {
            if !isExtracting {
                VStack {
                    Text(debName)
                        .font(.system(size: 60))
                    UIKitTextView(text: $dpkgLog)
                        .onAppear {
                            //update log
                        }
                    HStack {
                        Button(action: {
                            //install deb
                        }) {
                            Text("Install")
                        }
                        Button(action: {
                            withAnimation {
                                isExtracting = true
                            }
                        }) {
                            Text("Extract")
                        }
                        Button(action: {
                            isPresented = false
                        }) {
                            Text("Dismiss")
                        }
                    }
                }
                .transition(.opacity)
            } else {
                VStack {
                    TextField("Input destination path", text: $extractDest)
                        .disabled(extractToCurrentDir)
                    Button(action: {
                        extractToCurrentDir.toggle()
                    }) {
                        Image(systemName: extractToCurrentDir ? "checkmark.square" : "square")
                    }
                    Button(action: {
                        //extract deb
                    }) {
                        Text("Extract")
                    }
                }
                .transition(.opacity)
            }
        }
    }
}
