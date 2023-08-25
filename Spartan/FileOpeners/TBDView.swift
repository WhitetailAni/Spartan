//
//  TBDEditor.swift
//  Spartan
//
//  Created by RealKGB on 8/23/23.
//

import SwiftUI

enum tbdVersion { //this will only support tbdv3 at first since that's all I have on hand
	case one
	case two
	case three
	case four
}

struct TBD {
	var archs: [String]
	var platform: String
	var flags: String
	var pathToFramework: String
	var currentVersion: Int
	var compatibilityVersion: Int
	var objcConstraint: String
	var exports: TBDExport
}

struct TBDExport {
	var archs: [String]
	var symbols: [String]
	var classes: [String]
	var ivars: [String]
}

struct TBD3View: View {
	@State var filePath: String
	@State var fileName: String
	
	@State var localTBD: TBD = TBD(archs: [""], platform: "", flags: "", pathToFramework: "", currentVersion: 0, compatibilityVersion: 0, objcConstraint: "", exports: TBDExport(archs: [""], symbols: [""], classes: [""], ivars: [""]))
	
	init(filePath: String, fileName: String) {
		_fileName = State(initialValue: fileName)
		_filePath = State(initialValue: filePath)
		
		var tbdRaw = """
			The file is corrupted or is not a valid TBD file.
			Make sure you selected the proper file, and then try again.
			"""
		do {
			tbdRaw = try String(contentsOfFile: filePath + fileName)
		} catch {
			print("L")
		}
		let tbdArrayRaw: [Substring] = tbdRaw.split(separator: "\n")
		print(tbdArrayRaw)
		
		//let arch = tbdArrayRaw[0].dropFirst(2).dropLast(2).split(separator: ", ")
	}
	
    var body: some View {
        Text("gm")
    }
}
