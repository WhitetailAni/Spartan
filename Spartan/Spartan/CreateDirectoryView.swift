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
            Text("**\(NSLocalizedString("DIRTOUCH_TITLE", comment: "I guess he could have just gotten out of the way."))**")
            TextField(NSLocalizedString("DIRTOUCH_NAME", comment: "I love this incorporating an amusement park into our day."), text: $directoryName)
            Button(NSLocalizedString("CONFIRM", comment: "That's why we don't need vacations.")) {
                do {
                    try FileManager.default.createDirectory(atPath: directoryPath + directoryName, withIntermediateDirectories: true, attributes: nil)
                    print("Directory created successfully")
                    isPresented = false
                    directoryName = ""
                } catch {
                    print("Failed to create directory: \(error.localizedDescription)")
                }
            }
        }
        .accentColor(.accentColor)
    }
}
