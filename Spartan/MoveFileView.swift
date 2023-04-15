//
//  MoveFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct MoveFileView: View {
    @Binding var fileNames: [String]
    @Binding var filePath: String
    @Binding var multiMove: Bool
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
            if(!multiMove){
                TextField("Enter new file name (optional)", text: $newFileName)
            }
        
            Button("Confirm") {
                print(multiMove)
                print(fileNames)
                if(multiMove){
                    for fileName in fileNames {
                        moveFile(path: filePath + fileName, newPath: newFilePath + fileName)
                        print(fileName)
                    }
                } else if(newFileName == ""){
                    moveFile(path: filePath + fileNames[0], newPath: newFilePath + fileNames[0])
                } else {
                    moveFile(path: filePath + fileNames[0], newPath: newFilePath + newFileName)
                }
            
                print("File moved successfully")
                fileNames[0] = ""
                isPresented = false
            }
        }
        .onAppear {
            newFilePath = filePath
            if(!multiMove){
                newFileName = fileNames[0]
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
