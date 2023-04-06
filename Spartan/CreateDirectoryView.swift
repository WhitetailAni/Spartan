//
//  CreateDirectoryView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI

struct CreateDirectoryView: View {
    @State var directoryName: String = ""
    @State var directoryPath: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("**Create New Directory**")
            TextField("Enter directory name", text: $directoryName)
            Button("Confirm") {
                do {
                    try createDirectoryAtPath(path: directoryPath, directoryName: directoryName)
                    print("Directory created successfully")
                    isPresented = false
                    directoryName = ""
                } catch {
                    print("Failed to create directory: \(error.localizedDescription)")
                }
            }
            .padding()
        }
        .padding()
    }
    
    public func createDirectoryAtPath(path: String, directoryName: String) throws {
        let fileManager = FileManager.default
        let directoryPath = (path as NSString).appendingPathComponent(directoryName)
        try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
    }
}
