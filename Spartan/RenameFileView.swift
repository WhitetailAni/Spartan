//
//  RenameFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct RenameFileView: View {
    @Binding var fileName: String
    @Binding var newFileName: String
    @Binding var filePath: String
    @Binding var isPresented: Bool
    
    var body: some View {
        Text("**Rename File To**")
        TextField("Enter new file name", text: $newFileName)
        Button("Confirm") {
            print("confirm button action")
            print(fileName)
            print(newFileName)
            print(filePath)
            renameFile(path: filePath + fileName, fileName: filePath + newFileName)
            isPresented = false
        }
    }
    
    func renameFile(path: String, fileName: String) {
        do {
            print("")
            print("renameFile func")
            print(path)
            print(fileName)
            try FileManager.default.moveItem(atPath: path, toPath: fileName)
        } catch {
            print("Failed to rename file: \(error.localizedDescription)")
        }
    }
}
