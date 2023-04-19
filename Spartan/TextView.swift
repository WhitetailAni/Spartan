//
//  TextView.swift
//  Spartan
//
//  Created by RealKGB on 4/18/23.
//

import SwiftUI

struct TextView: View {
    let filePath: String
    @State private var fileContents: [String] = []
    @State private var textLineEditorShow = false
    @State private var textLineEditorString = ""
    @State private var textLineEditorIndex = 0

    var body: some View {
        VStack {
            Button(action: {
                print(stringArrayToString(inputArray: fileContents))
            }) {
                Text("test")
            }
            List(fileContents.indices, id: \.self) { index in
                Button(action: {
                    textLineEditorShow = true
                    textLineEditorString = fileContents[index]
                    textLineEditorIndex = index
                }) {
                    Text(fileContents[index])
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .focusable()
                }
            }
            .listStyle(GroupedListStyle())
        }
        .onAppear {
            readFile()
        }
        .sheet(isPresented: $textLineEditorShow, onDismiss: {
            readFile()
        }, content: {
            TextEditorView(textLineEditorShow: $textLineEditorShow, textLineEditorString: $textLineEditorString, textLineEditorIndex: textLineEditorIndex, textLineEditorArray: $fileContents)
        })
    }
    
    func readFile() {
        do {
            let url = URL(fileURLWithPath: filePath)
            let contents = try String(contentsOf: url, encoding: .utf8)
            fileContents = contents.components(separatedBy: "\n")
        } catch {
            print("Error loading file: \(error.localizedDescription)")
        }
    }
    
    func stringArrayToString(inputArray: [String]) -> String {
        @State var temp: String = ""
        for line in inputArray {
            temp = line + "\n"
        }
        print(temp)
        return temp
    }
}

struct TextEditorView: View {

    @Binding var textLineEditorShow: Bool
    @Binding var textLineEditorString: String
    @State var textLineEditorIndex: Int
    @Binding var textLineEditorArray: [String]
    
    var body: some View {
        TextField("Enter new text line", text: $textLineEditorString)
        Button(action: {
            textLineEditorArray[textLineEditorIndex] = textLineEditorString
            textLineEditorShow = false
        }) {
            Text("Confirm")
        }
    }
}
