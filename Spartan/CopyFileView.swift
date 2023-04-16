//
//  CopyFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct CopyFileView: View {
    @Binding var fileNames: [String]
    @Binding var filePath: String
    @Binding var multiSelect: Bool
    @State var newFileName: String = ""
    @State var newFilePath: String = ""
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack{
            Text("**Copy File To**")
            TextField("Enter new file path", text: $newFilePath, onEditingChanged: { (isEditing) in
                if !isEditing {
                    if(!(newFilePath.hasSuffix("/"))){
                        newFilePath = newFilePath + "/"
                    }
                }
            })
            if(fileNames.count == 1){
                TextField("Enter new file name (optional)", text: $newFileName)
            }
        
            Button("Confirm") {
                print(multiSelect)
                print(fileNames)
                if(multiSelect){
                    if(fileNames.count > 1){
                        for fileName in fileNames {
                            copyFile(path: filePath + fileName, newPath: newFilePath + fileName)
                            print(fileName)
                        }
                    } else {
                        copyFile(path: filePath + fileNames[0], newPath: newFilePath + newFileName)
                    }
                } else if(newFileName == ""){
                    copyFile(path: filePath + fileNames[0], newPath: newFilePath + fileNames[0])
                } else {
                    copyFile(path: filePath + fileNames[0], newPath: newFilePath + newFileName)
                }
            
                print("File copied successfully")
                fileNames[0] = ""
                multiSelect = false
                isPresented = false
            }
        }
        .onAppear {
            newFilePath = filePath
            if(!multiSelect){
                newFileName = fileNames[0]
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
