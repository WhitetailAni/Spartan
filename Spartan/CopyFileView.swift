//
//  CopyFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct CopyFileView: View {
    @Binding var fileName: String
    @Binding var filePath: String
    @State var newFileName: String = ""
    @State var newFilePath: String = ""
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack{
            Text("**Copy File To**")
            TextField("Enter new file path", text: $newFilePath)
            TextField("Enter new file name (optional)", text: $newFileName)
        
            Button("Confirm") {
                if(newFileName == ""){
                    copyFile(path: filePath + fileName, newPath: newFilePath + fileName)
                } else {
                    copyFile(path: filePath + fileName, newPath: newFilePath + newFileName)
                }
            
                print("File copied successfully")
                fileName = ""
                isPresented = false
            }
        }
    }
    
    func copyFile(path: String, newPath: String) {
        do {
            try FileManager.default.copyItem(atPath: path, toPath: newPath)
        } catch {
            print("Failed to copy file: \(error.localizedDescription)")
        }
    }
}

