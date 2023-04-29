//
//  PlistView.swift
//  Spartan
//
//  Created by RealKGB on 4/10/23.
//

import SwiftUI

struct PlistView: View {
    
    @Binding var filePath: String
    @Binding var fileName: String
    @State private var editorShow = false
    @State private var error = false
    
    @State var plistKey: String = ""
    @State var plistData: String = ""
    @State var plistKeyType: String = ""
    @State var plistDict: NSMutableDictionary = NSMutableDictionary()
    
    var body: some View {
        VStack {
            HStack {
                if(UserDefaults.settings.bool(forKey: "descriptiveTitles")){
                    Text(filePath)
                        .font(.system(size: 40))
                        .bold()
                        .multilineTextAlignment(.center)
                } else {
                    Text(fileName)
                        .font(.system(size: 40))
                        .bold()
                        .multilineTextAlignment(.center)
                }
                Button(action: {
                    if ((plistDict.write(toFile: filePath + fileName, atomically: true)) != nil) { } else {
                        error = true
                    }
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
                .alert(isPresented: $error) {
                    Alert(
                        title: Text(NSLocalizedString("ERROR", comment: "")),
                        message: nil,
                        dismissButton: .default(Text(NSLocalizedString("DISMISS", comment: "")))
                    )
                }
            }
            List(getContents(), id: \.self) { content in
                Button(action: {
                    editorShow = true
                    if let range = content.range(of: ": ") {
                        let plistKeySubstring = content.prefix(upTo: range.lowerBound)
                        plistKey = String(plistKeySubstring)
                    } else {
                        plistKey = "Please select a valid plist file"
                    }
                    if let startRange = content.range(of: ": "),
                        let endRange = content.range(of: " (", range: startRange.upperBound..<content.endIndex) {
                        let plistDataSubstring = content[startRange.upperBound..<endRange.lowerBound]
                        plistData = String(plistDataSubstring)
                    }
                    if let startRange = content.range(of: " ("),
                        let endRange = content.range(of: ")", range: startRange.upperBound..<content.endIndex) {
                        let plistKeyTypeSubstring = content[startRange.upperBound..<endRange.lowerBound]
                        plistKeyType = String(plistKeyTypeSubstring)
                    }
                }) {
                    Text(content)
                }
            }
        }
        .onAppear {
            plistDict = (NSDictionary(contentsOfFile: filePath + fileName)?.mutableCopy() as? NSMutableDictionary)!
        }
        .sheet(isPresented: $editorShow, content: {
            PlistEditorView(filePath: $filePath, fileName: $fileName, isPresented: $editorShow, plistDict: $plistDict, plistKey: $plistKey, plistData: $plistData, plistKeyType: $plistKeyType)
        })
    }
    
    private func getContents() -> [String] {
        var contents = [String]()
        if let data = FileManager.default.contents(atPath: filePath + fileName) {
            do {
                let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
                if let dict = plist as? [String: Any] {
                    for (key, value) in dict {
                        let valueString = processValue(value)
                        contents.append("\(key): \(valueString) (\(dataTypeString(value)))")
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        return contents
    }
    
    private func dataTypeString(_ value: Any) -> String {
        switch value {
        case is String:
            return "String"
        case is Int:
            return "Integer"
        case is Double:
            return "Double"
        case is Bool:
            return "Boolean"
        case is Data:
            return "Data"
        case is Date:
            return "Date"
        case is [Any]:
            return "Array"
        case is [String: Any]:
            return "Dictionary"
        default:
            return "Unknown"
        }
    } //these are data types and so will not be localized
    
    private func processValue(_ value: Any) -> String {
        switch value {
        case let str as String:
            return "\"\(str)\""
        case let int as Int:
            return "\(int)"
        case let double as Double:
            return "\(double)"
        case let bool as Bool:
            return "\(bool)"
        case let data as Data:
            return "\(data)"
        case let date as Date:
            return "\(date)"
        case let array as [Any]:
            let contents = array.map { processValue($0) }.joined(separator: ", ")
            return "[\(contents)]"
        case let dict as [String: Any]:
            let contents = dict.map { "\($0.key): \(processValue($0.value))" }.joined(separator: ", ")
            return "{\(contents)}"
        default:
            return "\(value)"
        }
    }

    
    private func getPlistType() -> PlistType {
        let data = FileManager.default.contents(atPath: filePath + fileName)
        if let data = data {
            var format: PropertyListSerialization.PropertyListFormat = .xml
            do {
                try PropertyListSerialization.propertyList(from: data, options: [], format: &format)
                return format == .binary ? .binary : .xml
            } catch {
                print(error.localizedDescription)
            }
        }
        return .unknown
    }
    
    private enum PlistType {
        case xml
        case binary
        case unknown
    }
}

struct PlistEditorView: View {

    @Binding var filePath: String
    @Binding var fileName: String
    @Binding var isPresented: Bool
    
    @Binding var plistDict: NSMutableDictionary
    @Binding var plistKey: String
    @Binding var plistData: String
    @Binding var plistKeyType: String
    
    @State private var parsedString: String = ""
    @State private var parsedInt = 0
    @State private var parsedArray: [Any] = []

    var body: some View {
        TextField(NSLocalizedString("PLIST_KEY", comment: ""), text: $plistKey, onCommit: {
            print("lol")
        })
        .onAppear {
            if(plistKeyType == "Integer") {
                parsedInt = plistDict[plistKey] as! Int
            } else if(plistKeyType == "String") {
                parsedString = plistDict[plistKey] as! String
            } else if(plistKeyType == "Array") {
                parsedArray = plistDict[plistKey] as! [Any]
            }
        }
        
        if(plistKeyType == "Integer") {
            StepperTV(value: $parsedInt)
        } else if(plistKeyType == "String") {
            TextField(NSLocalizedString("PLIST_DATA", comment: ""), text: $parsedString)
        } else if(plistKeyType == "Array") {
            Text("Support coming soon")
        } else if(plistKeyType == "Dictionary") {
            Text("Support coming soon (2x)")
        } else {
            Text("Unknown data type")
        }
        
        Button(action: {
            if(plistKeyType == "Integer") {
                plistDict.setValue(parsedInt, forKey: plistKey)
            } else if(plistKeyType == "String") {
                plistDict.setValue(parsedString, forKey: plistKey)
            }
            isPresented = false
        }) {
            Text(NSLocalizedString("CONFIRM", comment: ""))
        }
    }
}
