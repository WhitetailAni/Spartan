//
//  TextView.swift
//  Spartan
//
//  Created by RealKGB on 4/18/23.
//

import SwiftUI

struct TextView: View {
    @State var filePath: String
    @State var fileName: String
    @Binding var isPresented: Bool
    
    @State private var fileContents: [String] = []
    @State private var fileContentsToWrite: String = ""
    @State private var textEditorShow = false
    @State private var textEditorString = ""
    @State private var textEditorIndex = 0
    @State private var textEditorOldIndex = 0
    @State private var encoding: String.Encoding = .utf8
    @State private var index: Int = 0
    
    @State private var errorShow = false
    @State private var errorString = ""
    
    init(filePath: String, fileName: String, isPresented: Binding<Bool>) {
		_filePath = State(initialValue: filePath)
		_fileName = State(initialValue: fileName)
		_isPresented = isPresented
		
		do {
            let url = URL(fileURLWithPath: filePath + fileName)
            let fileData = try Data(contentsOf: url)
            let detectedEncoding = NSString.stringEncoding(for: fileData, encodingOptions: nil, convertedString: nil, usedLossyConversion: nil)
            if detectedEncoding != 0 {
                _encoding = State(initialValue: String.Encoding(rawValue: detectedEncoding))
            }
            let fileString = String(data: fileData, encoding: encoding)
            _fileContents = State(initialValue: fileString?.components(separatedBy: "\n") ?? ["An error occurred while trying to read the text file."])
        } catch {
            print("Error loading file: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack {
            if(!textEditorShow) {
				Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 40)
					}
					.font(.system(size: 40))
					.multilineTextAlignment(.center)
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
								RootHelperActs.rm(fullPath)
								RootHelperActs.mv(tempPath, fullPath)
							} else {
								try stringArrayToString(inputArray: fileContents).write(to: URL(fileURLWithPath: fullPath), atomically: true, encoding: encoding)
                            }
                            isPresented = false
                        } catch {
                            print("Failed to save file: \(error.localizedDescription)")
							errorString = "Failed to save file: \(error.localizedDescription)"
							errorShow = true
                        }
                    }) {
                        Image(systemName: "square.and.arrow.down")
                    }
					.alert(isPresented: $errorShow, content: {
						Alert(
							title: Text(NSLocalizedString("ERROR", comment: "")),
							message: Text(errorString),
							dismissButton: .default(Text(NSLocalizedString("DISMISS", comment: "")))
						)
					})
                    
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
    
    func stringArrayToString(inputArray: [String]) -> String {
        fileContentsToWrite = inputArray.joined(separator: "\n")
        return fileContentsToWrite
    }
}
