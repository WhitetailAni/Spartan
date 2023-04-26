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
        Text(NSLocalizedString("RENAME_TITLE", comment: "Boy, quite a bit of pomp..."))
            .bold()
        TextField(NSLocalizedString("RENAME_NAME", comment: "under the circumstances."), text: $newFileName)
        Button(NSLocalizedString("CONFIRM", comment: "Well, Adam, today we are men.")) {
            print(fileName)
            print(newFileName)
            print(filePath)
            renameFile(path: filePath + fileName, fileName: filePath + newFileName)
            isPresented = false
        }
    }
    
    func renameFile(path: String, fileName: String) {
        do {
            print(path)
            print(fileName)
            try FileManager.default.moveItem(atPath: path, toPath: fileName)
        } catch {
            print("Failed to rename file: \(error.localizedDescription)")
        }
    }
}
