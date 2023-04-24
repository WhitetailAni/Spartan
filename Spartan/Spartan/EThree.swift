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
    
    var body: some View {
    
        Text("**Welcome to Milliways**")
        
        Button(action: {
            print(directory)
        }) {
            Text("Print 'directory'")
        }
        
        Button(action: {
            print(files)
        }) {
            Text("Print 'files'")
        }
        
        Button(action: {
            print(multiSelectFiles)
        }) {
            Text("Print 'multiSelectFiles'")
        }
        
        Button(action: {
            print(fileWasSelected)
        }) {
            Text("Print 'fileWasSelected'")
        }
    }
}
