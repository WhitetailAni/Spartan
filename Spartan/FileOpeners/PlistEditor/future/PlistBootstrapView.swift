//
//  PlistBootstrapView.swift
//  Spartan
//
//  Created by RealKGB on 8/23/23.
//

import SwiftUI

struct PlistBootstrapView: View {
	@State var filePath: String
	@State var fileName: String

	@State var lmao: Double = 69
	@State var dataToPass: Any?
	
	@State var viewToLoad = 0
	@State var progress = 0.0
	
	init(filePath: String, fileName: String) {
        _filePath = State(initialValue: filePath)
        _fileName = State(initialValue: fileName)
		
		if let rawData = fileManager.contents(atPath: filePath + fileName) {
			do {
				let data = try PropertyListSerialization.propertyList(from: rawData, format: nil) as Any
				switch data {
				case is Bool:
					_viewToLoad = State(initialValue: 1)
					_dataToPass = State(initialValue: data as! Bool)
				case is Int:
					_viewToLoad = State(initialValue: 2)
					_dataToPass = State(initialValue: data as! Int)
				case is String:
					_viewToLoad = State(initialValue: 3)
					_dataToPass = State(initialValue: data as! String)
				case is [Any]:
					_viewToLoad = State(initialValue: 4)
					_dataToPass = State(initialValue: data as! [Any])
				case is [String: Any]:
					_viewToLoad = State(initialValue: 5)
					_dataToPass = State(initialValue: data as! [String: Any])
				case is Data:
					_viewToLoad = State(initialValue: 6)
					_dataToPass = State(initialValue: data as! Data)
				case is Date:
					_viewToLoad = State(initialValue: 7)
					_dataToPass = State(initialValue: data as! Date)
				default:
					_viewToLoad = State(initialValue: 0)
					print("death")
				}
			} catch {
				print("1394")
				_dataToPass = State(initialValue: ["The file specified is cannot be read.": "It may be corrupted, or be the wrong file.", "Select the proper file and then try again.":"Error ID 1394"])
			}
		} else {
			print("1395")
			_dataToPass = State(initialValue: ["The file specified is cannot be read.": "It may be corrupted, or be the wrong file.", "Select the proper file and then try again.":"Error ID 1395"])
		}
	}
	
    var body: some View {
		switch viewToLoad {
		default:
			UIKitProgressView(value: $progress, total: 100)
				.onAppear {
					DispatchQueue.main.asyncAfter(deadline: .now()) {
						while progress < 100 {
							progress += Double.random(in: 0..<7)
						}
					}
				}
		}
    }
}
