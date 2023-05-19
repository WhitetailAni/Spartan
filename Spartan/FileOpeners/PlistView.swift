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
    @State var i = 0
    @State var editOccurred = false
    @State var plistDictDisplay: [String] = []
    
    @State var valueToSet: Any? = nil
    @State var keyToSet: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
                        .font(.system(size: 40))
                        .bold()
                        .multilineTextAlignment(.center)
                }
                Spacer()
                Button(action: {
                    if(plistType() == 0) {
                        if (plistDict.write(toFile: filePath + fileName, atomically: true)) { } else {
                            error = true
                        }
                    } else if(plistType() == 1) {
                        let binaryPlistData: Data
                        do {
                            binaryPlistData = try PropertyListSerialization.data(fromPropertyList: plistDict, format: .binary, options: 0)
                            try binaryPlistData.write(to: URL(fileURLWithPath: filePath + fileName), options: .atomic)
                        } catch {
                            print("Error writing to plist: \(error.localizedDescription)")
                            return
                        }
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
            List(plistDictDisplay, id: \.self) { content in
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
            if(i == 0) {
                plistDict = (NSDictionary(contentsOfFile: filePath + fileName)?.mutableCopy() as? NSMutableDictionary) ?? NSMutableDictionary(objects: ["File is not a valid bplist or XML plist"], forKeys: ["Error" as NSCopying])
                plistDictDisplay = getContents()
                i += 1
            }
        }
        .sheet(isPresented: $editorShow, onDismiss: {
            if(editOccurred) {
                plistDict.removeObject(forKey: plistKey)
                plistDict.setObject(valueToSet as Any, forKey: keyToSet as NSCopying)
                plistDictDisplay = getContents()
            }
        }, content: {
            PlistEditorView(filePath: $filePath, fileName: $fileName, isPresented: $editorShow, plistDict: $plistDict, plistKey: $plistKey, plistData: $plistData, plistKeyType: $plistKeyType, editOccurred: $editOccurred, keyToSet: $keyToSet, valueToSet: $valueToSet, isNestedView: false)
        })
    }
    
    private func getContents() -> [String] {
        var contents = [String]()
        for (key, value) in plistDict {
            let valueString = processValue(value)
            contents.append("\(key): \(valueString) (\(dataTypeString(value)))")
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

    
    func plistType() -> Int {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return 2
        }
        
        let header = String(data: data.subdata(in: 0..<5), encoding: .utf8)
        let xmlHeader = "<?xml"
        let bplistHeader = "bplis"
        print(filePath, " ", header!)
        
        if header! == xmlHeader {
            return 0
        } else if header! == bplistHeader {
            return 1
        } else {
            return 2
        }
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
    
    @Binding var editOccurred: Bool
    
    @State private var parsedString: String = ""
    @State private var parsedInt = 0
    @State private var parsedArray: [Any] = []
    @State private var parsedDict: NSMutableDictionary = NSMutableDictionary()
    @State private var plistKeyNew: String = ""
    
    @Binding var keyToSet: String
    @Binding var valueToSet: Any?
    
    @State var arrayNestView = false
    @State var isNestedView: Bool


    var body: some View {
        TextField(NSLocalizedString("PLIST_KEY", comment: ""), text: $plistKeyNew)
        .onAppear {
            readData()
        }
        
        if(plistKeyType == "Integer") {
            StepperTV(value: $parsedInt, isHorizontal: true) { }
        } else if(plistKeyType == "String") {
            TextField(NSLocalizedString("PLIST_DATA", comment: ""), text: $parsedString)
        } else if(plistKeyType == "Array") {
            ScrollView {
                ForEach(0..<parsedArray.count, id: \.self) { index in
                    if(parsedArray[index] is Int) {
                        let value = parsedArray[index] as! Int
                        TextField(NSLocalizedString("PLIST_DATA", comment: ""), value: Binding (
                            get: { String(value) },
                            set: { parsedArray[index] = Double($0)! }), formatter: NumberFormatter()) { }
                            .padding()
                    } else if(parsedArray[index] is String) {
                        let value = parsedArray[index] as! String
                        TextField(NSLocalizedString("PLIST_DATA", comment: ""), text: Binding(
                            get: { value },
                            set: { parsedArray[index] = $0 }))
                    } else if(parsedArray[index] is Array<Any> || parsedArray[index] is NSArray) {
                        Text(NSLocalizedString("LOADING", comment: ""))
                            .onAppear {
                                isNestedView = true
                                arrayNestView = true
                            }
                    }
                }
                .padding()
            }
            .sheet(isPresented: $arrayNestView) {
                PlistEditorView(filePath: $filePath, fileName: $fileName, isPresented: $arrayNestView, plistDict: $plistDict, plistKey: $plistKey, plistData: $plistData, plistKeyType: $plistKeyType, editOccurred: $editOccurred, keyToSet: $keyToSet, valueToSet: $valueToSet, isNestedView: true)
            }
        } else if(plistKeyType == "Dictionary") {
            Text("Support coming soon")
        } else {
            Text("Unknown data type")
        }
        
        Button(action: {
            print(plistDict)
            setData()
        }) {
            Text(NSLocalizedString("CONFIRM", comment: ""))
        }
    }
    
    func readData() {
        editOccurred = false
        plistKeyNew = plistKey
        if(plistKeyType == "Integer") {
            parsedInt = plistDict[plistKey] as! Int
            valueToSet = parsedInt
        } else if(plistKeyType == "String") {
            parsedString = plistDict[plistKey] as! String
            valueToSet = parsedString
        } else if(plistKeyType == "Array") {
            parsedArray = plistDict[plistKey] as! [Any]
            valueToSet = parsedArray
        } else if(plistKeyType == "Dictionary") {
            if let nsDict = plistDict[plistKey] as? NSDictionary {
                parsedDict = NSMutableDictionary(dictionary: nsDict)
            } else {
                parsedDict = NSMutableDictionary(objects: ["Unable to read dictionary"], forKeys: ["Error" as NSCopying])
            }
            valueToSet = parsedDict
        }
        print(valueToSet!)
    }
    
    func setData() {
        if(plistKeyType == "Integer") {
            valueToSet = parsedInt
        } else if(plistKeyType == "String") {
            valueToSet = parsedString
        } else if(plistKeyType == "Array") {
            valueToSet = parsedArray
        } else if(plistKeyType == "Dictionary") {
            valueToSet = parsedDict
        } else {
            valueToSet = "ERROR"
        }
        keyToSet = plistKeyNew
        editOccurred = true
        isPresented = false
    }
}
