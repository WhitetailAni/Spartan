//
//  MoveFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct MoveFileView: View {
    @Binding var fileName: String
    @Binding var filePath: String
    @State var newFileName: String = ""
    @State var newFilePath: String = ""
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack{
            Text("**Move File To**")
            TextField("Enter new file path", text: $newFilePath, onEditingChanged: { (isEditing) in
                if !isEditing {
                    if(!(newFilePath.hasSuffix("/"))){
                        newFilePath = newFilePath + "/"
                    }
                }
            })
            TextField("Enter new file name (optional)", text: $newFileName)
        
            Button("Confirm") {
                if(newFileName == ""){
                    moveFile(path: filePath + fileName, newPath: newFilePath + fileName)
                } else {
                    moveFile(path: filePath + fileName, newPath: newFilePath + newFileName)
                }
            
                print("File moved successfully")
                fileName = ""
                isPresented = false
            }
        }
    }
    
    func moveFile(path: String, newPath: String) {
        do {
            try FileManager.default.moveItem(atPath: path, toPath: newPath)
        } catch {
            print("Failed to move file: \(error.localizedDescription)")
        }
    }
}
