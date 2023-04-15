//
//  PlistView.swift
//  Spartan
//
//  Created by RealKGB on 4/10/23.
//

import SwiftUI

import SwiftUI

struct PlistView: View {
    
    @Binding var filePath: String
    @Binding var fileName: String
    @State private var editorShow = false
    
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
                }) {
                    Text(content)
                }
            }
        }
        .sheet(isPresented: $editorShow, content: {
            Text("editor s0n")
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
