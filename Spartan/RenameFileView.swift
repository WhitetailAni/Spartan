//
//  RenameFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct RenameFileView: View {
    @Binding var fileName: String
    @Binding var filePath: String
    @State var newFileName: String = ""
    @Binding var isPresented: Bool
    
    var body: some View {
        Text("**Rename File To**")
        TextField("Enter new file name", text: $newFileName)
        Button("Confirm") {
            renameFile(path: filePath + fileName, fileName: filePath + newFileName)
            print("File renamed successfully")
            fileName = ""
            isPresented = false
        }
    }
    
    func renameFile(path: String, fileName: String) {
        do {
            try FileManager.default.moveItem(atPath: path, toPath: fileName)
        } catch {
            print("Failed to rename file: \(error.localizedDescription)")
        }
    }
}
