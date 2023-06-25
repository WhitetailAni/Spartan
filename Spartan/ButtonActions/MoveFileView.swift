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
    @Binding var multiSelect: Bool
    @State var newFileName: String = ""
    @State var newFilePath: String = ""
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack{
            Text(NSLocalizedString("MOVE_TITLE", comment: "- We are!"))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 60)
                }
            TextField(NSLocalizedString("DEST_PATH", comment: "- Bee-men."), text: $newFilePath, onEditingChanged: { (isEditing) in
                if !isEditing {
                    if(!(newFilePath.hasSuffix("/"))){
                        newFilePath = newFilePath + "/"
                    }
                }
            })
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
            
            if(fileNames.count == 1){
                TextField(NSLocalizedString("NEW_FILENAME", comment: "- Amen!") + NSLocalizedString("OPTIONAL", comment: "Hallelujah!"), text: $newFileName)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        
            Button(action: {
                print(multiSelect)
                print(fileNames)
                if(multiSelect){
                    if(fileNames.count > 1){
                        for fileName in fileNames {
                            moveFile(path: filePath + fileName, newPath: newFilePath + fileName)
                            print(fileName)
                        }
                    } else {
                        moveFile(path: filePath + fileNames[0], newPath: newFilePath + newFileName)
                    }
                } else if(newFileName == ""){
                    moveFile(path: filePath + fileNames[0], newPath: newFilePath + fileNames[0])
                } else {
                    moveFile(path: filePath + fileNames[0], newPath: newFilePath + newFileName)
                }
            
                print("File moved successfully")
                fileNames[0] = ""
                multiSelect = false
                isPresented = false
            }) {
                Text(NSLocalizedString("CONFIRM", comment: "Students, faculty, distinguished bees,"))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        }
        .onAppear {
            newFilePath = filePath
            if(!multiSelect){
                newFileName = fileNames[0]
            }
        }
    }
    
    func moveFile(path: String, newPath: String) {
        spawn(command: helperPath, args: ["mv", path, newPath], env: [], root: true)
    }
}
