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
	
	@State var plistDict: [PlistKey] = []
	
	@State var failedToWrite = false
	
	@State var editingSubView = false
	@State var subViewToShow: PlistKeyType = .bool
	@State var indexToEdit = 0
	
	@State var addKeyToPlist = false
	
	let fileManager = FileManager.default
	
	init(filePath: String, fileName: String) {
        _filePath = State(initialValue: filePath)
        _fileName = State(initialValue: fileName)
        
        print("hi")
        
        var tempDict: [String: Any] = [:]
        
        if let rawData = fileManager.contents(atPath: filePath + fileName) {
			do {
				if let dictionary = try PropertyListSerialization.propertyList(from: rawData, format: nil) as? [String: Any] {
					tempDict = dictionary
				} else {
					print("error 1288")
					tempDict = ["The plist file specified does not have a dictionary as its root.":"While these are valid plist files, they are not yet supported by Spartan.", "Check for an update to Spartan. If you're already up-to-date, wait for an update and then try again later.":"Error ID 127"]
				}
			} catch {
				print("1394")
				tempDict = ["The file specified is cannot be read.": "It may be corrupted, or be the wrong file.", "Select the proper file and then try again.":"Error ID 1394"]
			}
		} else {
			print("1394")
				tempDict = ["The file specified is cannot be read.": "It may be corrupted, or be the wrong file.", "Select the proper file and then try again.":"Error ID 1394"]
		}
			
		_plistDict = State(initialValue: PlistFormatter.swiftDictToPlistKeyArray(tempDict)) //THIS STUPID LINE OF CODE TOOK TWO MONTHS TO FIGURE OUT
		//I FORGOT TO INITIALIZE IT AND **I DIDNT NOTICE**, THATS WHY IT WASNT WORKING
		//I WAS SENDING THE DATA TO NOWHERE
		//KILL ME
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
			List(plistDict.indices, id: \.self) { index in
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
					Text(PlistFormatter.formatPlistKeyForDisplay(plistDict[index]))
				}
			}
		}
		.sheet(isPresented: $addKeyToPlist, content: {
			PlistAddDictView(plistDict: $plistDict, isPresented: $addKeyToPlist)
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