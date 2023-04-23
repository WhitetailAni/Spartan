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
            Text("**\(NSLocalizedString("TOUCH_TITLE", comment: "Everybody knows, sting someone, you die."))**")
            TextField(NSLocalizedString("TOUCH_NAME", comment: "Don't waste it on a squirrel."), text: $fileName)
            Button(NSLocalizedString("CONFIRM", comment: "Such a hothead.")) {
                FileManager.default.createFile(atPath: filePath + fileName, contents: nil, attributes: nil)
                print("File created successfully")
                fileName = ""
                isPresented = false
            }
        }
        .accentColor(.accentColor)
    }
}
