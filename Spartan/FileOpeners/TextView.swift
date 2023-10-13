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
    @State private var index: Int = 0
    
    var body: some View {
        VStack {
            if(!textEditorShow) {
                HStack {
                    Button(action: {
                        if(index == 0) {
                            fileContents.insert("", at: 1)
                        } else {
                            fileContents.insert("", at: index)
                        }
                    }) {
                        Text("\(NSLocalizedString("LINEADD", comment: "- Hear about Frankie?")) \(index)")
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    Button(action: {
                        fileContents.remove(at: index)
                    }) {
                        Text("\(NSLocalizedString("LINEREMOVE", comment: "- Yeah.")) \(index)")
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    VStack {
						Text(LocalizedString("LINESELECTED"))
							.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
								view.scaledFont(name: "BotW Sheikah Regular", size: 25)
							}
							.font(.system(size: 25))
							.multilineTextAlignment(.center)
						StepperTV(value: $index, isHorizontal: true) { }
                    }
                    Spacer()
                    Button(action: {
                        do {
							let fullPath = filePath + fileName
							if filePathIsNotMobileWritable(fullPath) {
								try stringArrayToString(inputArray: fileContents).write(to: URL(fileURLWithPath: tempPath), atomically: true, encoding: encoding)
								RootHelperActs.mv(tempPath, fullPath)
							} else {
								try stringArrayToString(inputArray: fileContents).write(to: URL(fileURLWithPath: fullPath), atomically: true, encoding: encoding)
                            }
                        } catch {
                            print("Failed to save file: \(error.localizedDescription)")
                        }
                    }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                }
                List(fileContents.indices, id: \.self) { indexB in
                    HStack {
                        if(indexB == index) {
                            Text(String(indexB))
                                .foregroundColor(.blue)
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
                        } else {
                            Text(String(indexB))
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
                        }
                        Button(action: {
                            withAnimation {
                                textEditorShow = true
                            }
                            textEditorString = fileContents[indexB]
                            textEditorIndex = indexB
                        }) {
                            if(indexB == index) {
                                Text(fileContents[indexB])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.blue)
                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                    }
                            } else {
                                Text(fileContents[indexB])
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                    }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
                .transition(.opacity)
            } else {
                HStack {
                    TextField(NSLocalizedString("LINEADD_DESCRIPTION", comment: "- You going to the funeral?"), text: $textEditorString)
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                    Button(action: {
                        fileContents[textEditorIndex] = textEditorString
                        print(fileContents)
                        withAnimation {
                            textEditorShow = false
                        }
                    }) {
                        Text(NSLocalizedString("CONFIRM", comment: "- No, I'm not going."))
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
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
