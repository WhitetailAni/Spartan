//
//  HexView.swift
//  Spartan
//
//  Created by RealKGB on 5/1/23.
//

import SwiftUI

//welcome to my amazing hex editor.
//it increments by 4 bytes each row. to edit, use the provided TextFields and type your hex manually like a REAL programmer
//seriously though, why are you expecting anything better? i'm severely limited with what I can create because you have to navigate with a circle pad on a remote

//im updating it to be more like the text editor so you can select lines and add/remove at specific lines, its just a headache and i dont have the mental space rn

struct HexView: View {
    @State var filePath: String
    @State var fileName: String
    @Binding var isPresented: Bool
    
    @State private var hexString: String = ""
    @State private var hexArray: [String] = []
    @State private var index: Int = 0
    
    @State private var errorShow = false
    @State private var errorString = ""
    
    init(filePath: String, fileName: String, isPresented: Binding<Bool>) {
		_filePath = State(initialValue: filePath)
		_fileName = State(initialValue: fileName)
		_isPresented = isPresented
		
		var data: Data
		var tempArray: [String] = []
		var tempString = ""
		do {
			data = try Data(contentsOf: URL(fileURLWithPath: filePath + fileName))
			tempString = data.map { String(format: "%02hhx", $0) }.joined(separator: "")
			if tempString == "" {
				tempArray = [""]
			} else {
				for index in stride(from: 0, to: tempString.count, by: 8) {
					let startIndex = tempString.index(tempString.startIndex, offsetBy: index)
					let endIndex = tempString.index(startIndex, offsetBy: 8, limitedBy: tempString.endIndex) ?? tempString.endIndex
					let chunk = String(tempString[startIndex..<endIndex])
					let one = chunk.prefix(2)
					let two = chunk.dropFirst(2).prefix(2)
					let three = chunk.dropFirst(4).prefix(2)
					let four = chunk.dropFirst(6).prefix(2)
					tempArray.append("\(one)\(two)\(three)\(four)")
					//hacky but no out of bounds
				}
			}
		} catch {
			tempArray = ["The file is invalid or not supported. Please make sure the file is not corrupted and then try again.", "(Error ID 1.2)"]
		}
		_hexString = State(initialValue: tempString)
		_hexArray = State(initialValue: tempArray)
	}

    var body: some View {
		VStack {
			Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                .font(.system(size: 40))
                .multilineTextAlignment(.center)
			HStack {
				Button(action: {
                        if(index == 0) {
                            hexArray.insert("", at: 1)
                        } else {
                            hexArray.insert("", at: index)
                        }
                    }) {
                        Text("\(NSLocalizedString("LINEADD", comment: "- Hear about Frankie?")) \(index)")
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    Button(action: {
						hexArray.remove(at: index)
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
						StepperTV(value: $index, isHorizontal: true) {
							if index < 0 {
								index = 0
							}
							if index >= hexArray.count {
								index = hexArray.count - 1
							}
							print(hexArray.count)
						}
                    }
				
				Spacer()
				Button(action: {
					var cleanedHexString: String = ""
					let newData = Data(fromHexEncodedString: cleanedHexString) // convert hex string to data object
					do {
						let fullPath = filePath + fileName
						if filePathIsNotMobileWritable(fullPath) {
							try newData?.write(to: URL(fileURLWithPath: tempPath)) // write data to file
							RootHelperActs.rm(fullPath)
							RootHelperActs.mv(tempPath, fullPath)
						} else {
							try newData?.write(to: URL(fileURLWithPath: fullPath)) // write data to file
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
			
			List(hexArray.indices, id: \.self) { indexB in
				if hexArray == ["The file is invalid or not supported. Please make sure the file is not corrupted and then try again. (Error ID 2)"] {
					Text(hexArray[0])
				} else {
					let hexValue = 0x0 + indexB * 4
					var hexString = String(hexValue, radix: 16)
					HStack {
						if(indexB == index) {
							Text("0x\(hexString)")
								.foregroundColor(.blue)
								.font(.custom("SF Mono Regular", size: 30))
								.onAppear {
									while (hexString.count < 8) {
										hexString = hexString + " "
									}
								}
								.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
									view.scaledFont(name: "BotW Sheikah Regular", size: 40)
								}
							
							TextField(NSLocalizedString("HEX_DATA", comment: ""), text: $hexArray[indexB], onCommit: {
								sanitizeHex(indexB)
							})
							.frame(width: UIScreen.main.nativeBounds.width - 500)
							.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
								view.scaledFont(name: "BotW Sheikah Regular", size: 40)
							}
							
							Text(String(data: Data(fromHexEncodedString: hexArray[indexB]) ?? Data(), encoding: .utf8) ?? "Unable to read data")
								.foregroundColor(.blue)
								.font(.custom("SF Mono Regular", size: 30))
								.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
									view.scaledFont(name: "BotW Sheikah Regular", size: 40)
								}
								
						} else {
							Text("0x\(hexString)")
								.font(.custom("SF Mono Regular", size: 30))
								.onAppear {
									while (hexString.count < 8) {
										hexString = hexString + " "
									}
								}
								.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
									view.scaledFont(name: "BotW Sheikah Regular", size: 40)
								}
								
							TextField(NSLocalizedString("HEX_DATA", comment: ""), text: $hexArray[indexB], onCommit: {
								sanitizeHex(indexB)
							})
							.frame(width: UIScreen.main.nativeBounds.width - 500)
							.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
								view.scaledFont(name: "BotW Sheikah Regular", size: 40)
							}
							
							Text(String(data: Data(fromHexEncodedString: hexArray[indexB]) ?? Data(), encoding: .utf8) ?? "Unable to read data")
								.font(.custom("SF Mono Regular", size: 30))
								.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
									view.scaledFont(name: "BotW Sheikah Regular", size: 40)
								}
						}
					}
				}
			}
        }
    }
    
    func sanitizeHex(_ indexB: Int) {
		if hexArray[indexB].count > 8 {
			hexArray[indexB] = String(hexArray[indexB].prefix(8))
		}
		
		hexArray[indexB] = hexArray[indexB].replacingOccurrences(of: "a", with: "A")
		hexArray[indexB] = hexArray[indexB].replacingOccurrences(of: "b", with: "B")
		hexArray[indexB] = hexArray[indexB].replacingOccurrences(of: "c", with: "C")
		hexArray[indexB] = hexArray[indexB].replacingOccurrences(of: "d", with: "D")
		hexArray[indexB] = hexArray[indexB].replacingOccurrences(of: "e", with: "E")
		hexArray[indexB] = hexArray[indexB].replacingOccurrences(of: "f", with: "F")
		//how do i make this less bad. there is *definitely* a better way to do this but i dont know it
		
		for i in 0..<hexArray[indexB].count {
			let char = hexArray[indexB][i]
			if ((char < "0" || char > "9") && (char < "A" || char > "F")) {
				let index = hexArray[indexB].index(hexArray[indexB].startIndex, offsetBy: i)
				hexArray[indexB].replaceSubrange(index...index, with: "")
			}
		}
		
		while hexArray[indexB].count < 8 {
			hexArray[indexB].append("0")
		}
	}
}
