//
//  EThree.swift
//  Spartan
//
//  Created by RealKGB on 4/23/23.
//

import SwiftUI

struct E3: View {
    
    @Binding var directory: String
    @Binding var files: [String]
    @Binding var multiSelectFiles: [String]
    @Binding var fileWasSelected: [Bool]
    @Binding var showSubView: [Bool]
    
    var body: some View {
        let paddingInt: CGFloat = -7
        let opacityInt: CGFloat = 1.0
        let buttonWidth: CGFloat = 500
        let buttonHeight: CGFloat = 30
    
        Text("Welcome to Milliways")
            .font(.system(size: 69))
            .bold()
            .padding(paddingInt)
            .opacity(opacityInt)
        
        Button(action: {
            print(directory)
        }) {
            Text("Print 'directory'")
                .frame(width: buttonWidth, height: buttonHeight)
        }
        .padding(paddingInt)
            .opacity(opacityInt)
        
        
        Button(action: {
            print("\(files), \(files.count)")
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
            print("What is the answer to Life, the Universe, and Everything?")
        }) {
            Text("42")
                .frame(width: buttonWidth, height: buttonHeight)
        }
        .padding(10)
    }
}
