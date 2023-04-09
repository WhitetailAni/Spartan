//
//  CreateFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct CreateFileView: View {
    @State var fileName: String = ""
    @State var filePath: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("**Create New File**")
            TextField("Enter file name", text: $fileName)
            Button("Confirm") {
                do {
                    try createFileAtPath(path: filePath, fileName: fileName)
                    print("File created successfully")
                    fileName = ""
                    isPresented = false
                } catch {
                    print("Failed to create file: \(error.localizedDescription)")
                }
            }
        }
        .accentColor(.accentColor)
    }
    
    func createFileAtPath(path: String, fileName: String) throws {
        let fileManager = FileManager.default
        let filePath = (path as NSString).appendingPathComponent(fileName)
        fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
    }
}
