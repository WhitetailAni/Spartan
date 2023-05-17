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
    @State private var index: UInt = 0
    @State private var indexPro: Int = 0
    
    var body: some View {
        VStack {
            if(!textEditorShow) {
                HStack {
                    Button(action: {
                        fileContents.insert("", at: Int(index))
                    }) {
                        Text("\(NSLocalizedString("LINEADD", comment: "- Hear about Frankie?")) \(index)")
                    }
                    Button(action: {
                        fileContents.remove(at: Int(index))
                    }) {
                        Text("\(NSLocalizedString("LINEREMOVE", comment: "- Yeah.")) \(index)")
                    }
                    StepperTV(value: Binding (
                            get: { Int(index) },
                            set: { indexPro = $0 }), isHorizontal: true) {
                                if(!(indexPro < 0) && !(index >= fileContents.count)) {
                                    index = UInt(indexPro)
                                    print("success")
                                }
                                if(index == fileContents.count) {
                                    indexPro -= 1
                                    if(indexPro < 0) {
                                        indexPro = 0
                                        index = UInt(indexPro)
                                    }
                                    print("equal")
                                }
                                if(index > fileContents.count) {
                                    indexPro = Int(index)
                                    print("greater")
                                } //this is bad logic and will be fixed
                                print(fileContents.count)
                                print(indexPro)
                                print(index)
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
                List(fileContents.indices, id: \.self) { indexB in
                    HStack {
                        if(indexB == Int(index)) {
                            Text(String(indexB))
                                .foregroundColor(.blue)
                        } else {
                            Text(String(indexB))
                        }
                        Button(action: {
                            withAnimation {
                                textEditorShow = true
                            }
                            textEditorString = fileContents[indexB]
                            textEditorIndex = indexB
                        }) {
                            if(indexB == Int(index)) {
                                Text(fileContents[indexB])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.blue)
                            } else {
                                Text(fileContents[indexB])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .transition(.opacity)
            } else {
                HStack {
                    TextField(NSLocalizedString("LINEADD_DESCRIPTION", comment: "- You going to the funeral?"), text: $textEditorString)
                    Button(action: {
                        fileContents[textEditorIndex] = textEditorString
                        print(fileContents)
                        withAnimation {
                            textEditorShow = false
                        }
                    }) {
                        Text(NSLocalizedString("CONFIRM", comment: "- No, I'm not going."))
                    }
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            readFile()
        }
        .onExitCommand {
            if(textEditorShow){
                withAnimation {
                    textEditorShow = false
                }
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
