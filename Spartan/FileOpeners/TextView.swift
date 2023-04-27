//
//  TextView.swift
//  Spartan
//
//  Created by RealKGB on 4/18/23.
//

import SwiftUI

struct TextView: View {
    @Binding var filePath: String
    @Binding var fileName: String
    @Binding var isPresented: Bool
    @State private var fileContents: [String] = []
    @State private var fileContentsToWrite: String = ""
    @State private var textEditorShow = false
    @State private var textEditorString = ""
    @State private var textEditorIndex = 0
    @State private var textEditorOldIndex = 0
    @State private var encoding: String.Encoding = .utf8
    
    var body: some View {
        VStack {
            if(!textEditorShow) {
                HStack {
                    Button(action: {
                        fileContents.append("")
                    }) {
                        Text(NSLocalizedString("LINEADD", comment: "- Hear about Frankie?"))
                    }
                    Button(action: {
                        fileContents.remove(at: fileContents.count-1)
                    }) {
                        Text(NSLocalizedString("LINEREMOVE", comment: "- Yeah."))
                    }
                    Spacer()
                    Button(action: {
                        do {
                            try stringArrayToString(inputArray: fileContents).write(to: URL(fileURLWithPath: filePath + fileName), atomically: true, encoding: encoding)
                        } catch {
                            print("Failed to save file: \(error.localizedDescription)")
                        }
                    }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                List(fileContents.indices, id: \.self) { index in
                    Button(action: {
                        textEditorShow = true
                        textEditorString = fileContents[index]
                        textEditorIndex = index
                    }) {
                        Text(fileContents[index])
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .listStyle(GroupedListStyle())
            } else {
                TextField(NSLocalizedString("LINEADD_DESCRIPTION", comment: "- You going to the funeral?"), text: $textEditorString)
                Button(action: {
                    fileContents[textEditorIndex] = textEditorString
                    print(fileContents)
                    textEditorShow = false
                }) {
                    Text(NSLocalizedString("CONFIRM", comment: "- No, I'm not going."))
                }
            }
        }
        .onAppear {
            readFile()
        }
        .onExitCommand {
            if(textEditorShow){
                textEditorShow = false
            } else {
                isPresented = false
            }
        }
    }
    
    func readFile() {
        do {
            let url = URL(fileURLWithPath: filePath + fileName)
            let fileData = try Data(contentsOf: url)
            let detectedEncoding = NSString.stringEncoding(for: fileData, encodingOptions: nil, convertedString: nil, usedLossyConversion: nil)
            if detectedEncoding != 0 {
                encoding = String.Encoding(rawValue: detectedEncoding)
            }
            let fileString = String(data: fileData, encoding: encoding)
            fileContents = fileString?.components(separatedBy: "\n") ?? ["An error occurred while trying to read the text file."]
        } catch {
            print("Error loading file: \(error.localizedDescription)")
        }
    }
    
    func stringArrayToString(inputArray: [String]) -> String {
        fileContentsToWrite = inputArray.joined(separator: "\n")
        return fileContentsToWrite
    }
}
