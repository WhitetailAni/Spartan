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
        if(fileNames.count == 0) {
            Text("Please select at least one file")
        } else {
            VStack {
                Text(NSLocalizedString("COPY_TITLE", comment: "please welcome Dean Buzzwell."))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 60)
                    }
                TextField(NSLocalizedString("DEST_PATH", comment: "Welcome, New Hive City graduating class of..."), text: $newFilePath, onEditingChanged: { (isEditing) in
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
                    TextField(NSLocalizedString("NEW_FILENAME", comment: "...9:15.") + NSLocalizedString("OPTIONAL", comment: "That concludes our ceremonies."), text: $newFileName)
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
                }) {
                    Text(NSLocalizedString("CONFIRM", comment: "And begins your career at Honex Industries!"))
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
    }
    
    func copyFile(path: String, newPath: String) {
        spawn(command: helperPath, args: ["cp", path, newPath], env: [], root: true)
    }
}
