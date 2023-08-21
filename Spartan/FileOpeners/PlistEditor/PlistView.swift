//
//  PlistView.swift
//  Spartan
//
//  Created by RealKGB on 4/10/23.
//

import SwiftUI

struct PlistView: View {
	@State var filePath: String
	@State var fileName: String
	@State var plistData: Data = Data()
	
	@State var rawPlistDict: [String: Any] = [:]
	@State var plistDict: [PlistKey] = []
	
	@State var failedToWrite = false
	
	@State var editingSubView = false
	@State var subViewToShow: PlistKeyType = .bool
	@State var indexToEdit = 0
	
	@State var addKeyToPlist = false
	
	let fileManager = FileManager.default
	
	init(filePath: String, fileName: String, plistType: Int) {
        _filePath = State(initialValue: filePath)
        _fileName = State(initialValue: fileName)
        
		let rawData = fileManager.contents(atPath: filePath + fileName)
		do {
            let plistData = try PropertyListSerialization.propertyList(from: rawData!, options: [], format: nil)
            rawPlistDict = plistData as? [String: Any] ?? ["The file specified is cannot be read.": "It may be corrupted, or it may not be a plist file.", "Make sure you select the proper file and then try again.":"Error ID 1394"]
        } catch {
            print("Error parsing plist: \(error)")
        }
			
		plistDict = PlistFormatter.swiftDictToPlistKeyArray(rawPlistDict)
	}
	
	var body: some View {
		VStack {
			HStack {
				Button(action: {
					addKeyToPlist = true
				}) {
					Image(systemName: "plus")
				}
				Spacer()
				Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
					.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
						view.scaledFont(name: "BotW Sheikah Regular", size: 40)
					}
					.font(.system(size: 40))
					.multilineTextAlignment(.center)
					.padding(-10)
					.focusable(true)
				Spacer()
				Button(action: {
					writeDictToPlist(PlistFormatter.plistKeyArrayToSwiftDict(plistDict))
				}) {
					Image(systemName: "square.and.arrow.down")
				}
				.alert(isPresented: $failedToWrite, content: {
					Alert(title: Text(NSLocalizedString("PLIST_FAILEDTOSAVE", comment: "9999999")), message: Text(NSLocalizedString("PLIST_FAILEDTOSAVEINFO", comment: "I Saw A Deer Today")), dismissButton: .default(Text(NSLocalizedString("DISMISS", comment: "Your Not A Good Person"))))
				})
			}
			ForEach(plistDict.indices, id: \.self) { index in
				Button(action: {
					if(plistDict[index].type == .bool) {
						let bool = plistDict[index].value as! Bool
						if bool {
							plistDict[index].value = false
						} else {
							plistDict[index].value = true
						}
					} else {
						indexToEdit = index
					}
					print(plistDict[index])
				}) {
					if (plistDict[index].type == .bool) {
						Image(systemName: plistDict[index].value as! Bool ? "checkmark.square" : "square")
					}
					Text(PlistFormatter.formatPlistKey(plistDict[index]))
				}
			}
		}
		.sheet(isPresented: $addKeyToPlist, content: {
			PlistAddView(plistDict: $plistDict)
		})
		.sheet(isPresented: $editingSubView, content: {
			/*switch subViewToShow {
			case .bool:
				
			}*/
		})
	}
	
	func writeDictToPlist(_ dict: [String: Any]) {
		let nsdict = dict as NSDictionary
		do {
			try nsdict.write(to: URL(fileURLWithPath: filePath + fileName))
		} catch {
			failedToWrite = true
		}
	}
}
