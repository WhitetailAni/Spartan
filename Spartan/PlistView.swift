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
    
    @State var plistKey: String = ""
    @State var plistData: String = ""
    @State var plistKeyType: String = ""
    
    var body: some View {
        VStack {
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
            List(getContents(), id: \.self) { content in
                Button(action: {
                    editorShow = true
                    if let range = content.range(of: ": ") {
                        let plistKeySubstring = content.prefix(upTo: range.lowerBound)
                        plistKey = String(plistKeySubstring)
                    } else {
                        plistKey = "An error occurred while trying to read the key type."
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
                    print(plistKey)
                    print(plistData)
                    print(plistKeyType)
                }) {
                    Text(content)
                }
            }
        }
        .sheet(isPresented: $editorShow, content: {
            PlistEditorView(plistKey: $plistKey, plistData: $plistData, plistKeyType: $plistKeyType)
        })
    }
    
    private func getContents() -> [String] {
        var contents = [String]()
        if let data = FileManager.default.contents(atPath: filePath) {
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
    }
    
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
        let data = FileManager.default.contents(atPath: filePath)
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
    
    @Binding var plistKey: String
    @Binding var plistData: String
    @Binding var plistKeyType: String
    @State private var plistDataString: String = ""
    @State private var plistDataEditable: String = ""
    @State private var plistDataBoolean = false
    //let testString = """
            //["AppleTVOS", "iPhoneOS", "watchOS", "bridgeOS", "macOS"]
            //"""
    
    let testString = "[3, 4, 5, 6]"
    var body: some View {
        TextField("Enter new key", text: $plistKey)
        .onAppear {
            plistDataEditable = plistData
            /*print("plist key type: " + plistKeyType)
            print("plist data: " + plistData)
            print("plist key string: " + plistDataEditable)*/
        }
        if(plistKeyType == "String"){
            TextField("Enter new String", text: $plistDataString)
            .onAppear {
                plistDataString = plistData.trimmingCharacters(in: CharacterSet(charactersIn: """
                "
                """))
            }
        } else if(plistKeyType == "Integer" || plistKeyType == "Double"){
            TextField("Enter new Number", text: $plistDataEditable)
                .keyboardType(.decimalPad)
        } else if(plistKeyType == "Boolean"){
            Button(action: {
                plistDataBoolean.toggle()
            }) {
                Image(systemName: plistDataBoolean ? "checkmark.square" : "square")
            }
            .onAppear {
                if(plistData == "1"){
                    plistDataBoolean = true
                }
            }
        } else if(plistKeyType == "Date"){
            TextField("Enter new Date", text: $plistDataEditable)
        } else if(plistKeyType == "Array"){
            /*let elementCount = ", "
            ForEach(testString, id: \.self) { number in
                Text("\(number)")
            }
            .onAppear {
                if(plistDataEditable.prefix(2) == """
                ["
                """){
                    let pattern = """
                    ", "
                    """
                    print("even before")
                    print(testString)
                    var parsedArray = testString.split(separator: pattern.first!, maxSplits: Int.max, omittingEmptySubsequences: true).map { String($0) }
                    let yeet = ["[", """
                    ", "
                    """, "]"]
                    print("before")
                    print(parsedArray)
                    for _ in 0..<parsedArray.count {
                        parsedArray.removeAll {
                            yeet.contains($0)
                        }
                    }
                    print("after")
                    print(parsedArray)
                } else {
                    let pattern = ", "
                    print("even before")
                    print(testString)
                    var parsedArray = testString.trimmingCharacters(in: ["[", "]"])
                     .components(separatedBy: ", ")
                     .compactMap { Int($0) }
                    for i in 0..<parsedArray.count {
                        print(parsedArray[i])
                    }
                    print("after")
                    print(parsedArray)
                }
            }*/
        }
    }
}
