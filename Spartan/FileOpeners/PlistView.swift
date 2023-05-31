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
                    print(plistKey)
                    print(plistKeyType)
                    editorShow = true
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
            plistDict.setValue(valueToSet, forKey: plistKey)
        }, content: {
            switch plistKeyType {
            case "Boolean":
                PlistBoolView(key: $plistKey, bool: Binding (
                    get: { plistDict.value(forKey: plistKey) as! Bool },
                    set: { valueToSet = $0 }), isInDict: true)
            case "Integer":
                PlistIntView(key: $plistKey, int: Binding (
                    get: { plistDict.value(forKey: plistKey) as! Int },
                    set: { valueToSet = $0 }), isInDict: true)
            case "String":
                PlistStringView(key: $plistKey, string: Binding (
                    get: { plistDict.value(forKey: plistKey) as! String },
                    set: { valueToSet = $0 }), isInDict: true)
            case "Array":
                PlistArrayView(key: $plistKey, array: Binding (
                    get: { plistDict.value(forKey: plistKey) as! [Any] },
                    set: { valueToSet = $0 }), isInDict: true)
            case "NSMutableDictionary":
                PlistDictView(key: $plistKey, dict: Binding (
                    get: { plistDict.value(forKey: plistKey) as! NSMutableDictionary },
                    set: { valueToSet = $0 }), isInDict: true)
            default:
                Text("Unknown data type")
            }
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

struct PlistDictView: View {
    @Binding var key: String
    @Binding var dict: NSMutableDictionary
    @State var isInDict: Bool
    @State private var mutableDict: NSMutableDictionary = NSMutableDictionary()

    var body: some View {
        Text("gm")
    }
}

struct PlistKeyView: View {
    @State var show: Bool
    @Binding var key: String
    
    var body: some View {
        if(show) {
            TextField(NSLocalizedString("PLIST_KEY", comment: ""), text: $key)
        }
    }
}

struct PlistBoolView: View {
    
    @Binding var key: String
    @Binding var bool: Bool
    @State var isInDict: Bool
    
    var body: some View {
        PlistKeyView(show: isInDict, key: $key)
        Button(action: {
            bool.toggle()
        }) {
            Image(systemName: bool ? "checkmark.square" : "square")
        }
    }
}

struct PlistIntView: View {
    @Binding var key: String
    @Binding var int: Int
    @State var isInDict: Bool

    var body: some View {
        PlistKeyView(show: isInDict, key: $key)
        StepperTV(value: $int, isHorizontal: true) { }
    }
}

struct PlistStringView: View {
    @Binding var key: String
    @Binding var string: String
    @State var isInDict: Bool
    
    var body: some View {
        PlistKeyView(show: isInDict, key: $key)
        TextField(NSLocalizedString("PLIST_DATA", comment: ""), text: $string)
    }
}

struct PlistArrayView: View {
    @Binding var key: String
    @Binding var array: [Any]
    @State private var mutableArray: [Any] = [Any]()
    @State var isInDict: Bool
    @State private var fakeKey = ""
    @State private var selectedIndex = 0
    @State private var topBarIndex = 0
    @State private var showSheet = false
    @State private var addViewShow = false
    @State private var fakeDict = NSMutableDictionary()
    
    var body: some View {
        HStack {
            Button(action: {
                addViewShow = true
            }) {
                Text(NSLocalizedString("PLISTARR_ADD", comment: "") + String(topBarIndex))
            }
            Button(action: {
                mutableArray.remove(at: topBarIndex)
            }) {
                Text(NSLocalizedString("PLISTARR_REMOVE", comment: "") + String(topBarIndex))
            }
            StepperTV(value: $topBarIndex, isHorizontal: true) { }
            Spacer()
            Button(action: {
                array = mutableArray
            }) {
                Image(systemName: "square.and.arrow.down")
            }
        }
        List {
            PlistKeyView(show: isInDict, key: $key)
            ForEach(mutableArray.indices, id: \.self) { index in
                HStack {
                    if(index == topBarIndex) {
                        Text(String(index))
                            .foregroundColor(.blue)
                    } else {
                        Text(String(index))
                    }
                    Button(action: {
                        selectedIndex = 0
                        showSheet = true
                    }) {
                        Text(mutableArray[index] as! String)
                    }
                }
            }
        }
        .sheet(isPresented: $showSheet, content: {
            switch mutableArray[selectedIndex] {
            case is Bool:
            //if(array[index] is Bool) {
                PlistBoolView(key: $fakeKey, bool: $mutableArray[selectedIndex] as! Binding<Bool>, isInDict: false)
            //} else if(array[index] is Int) {
            case is Int:
                PlistIntView(key: $fakeKey, int: $mutableArray[selectedIndex] as! Binding<Int>, isInDict: false)
            //} else if(array[index] is String) {
            case is String:
                PlistStringView(key: $fakeKey, string: $mutableArray[selectedIndex] as! Binding<String>, isInDict: false)
            //} else if(array[index] is [Any]) {
            case is [Any]:
                PlistArrayView(key: $fakeKey, array: $mutableArray[selectedIndex] as! Binding<[Any]>, isInDict: false)
            //} else if(array[index] is NSMutableDictionary) {
            case is NSMutableDictionary:
                PlistDictView(key: $fakeKey, dict: $mutableArray[selectedIndex] as! Binding<NSMutableDictionary>, isInDict: false)
            //}
            default:
                Text(NSLocalizedString("PLIST_UNKNOWNTYPE", comment: ""))
            }
        })
        .sheet(isPresented: $addViewShow, content: {
            PlistAddView(array: $mutableArray, dict: $fakeDict, index: topBarIndex, isAddingToDict: false)
        })
    }
}

struct PlistAddView: View {

    @Binding var array: [Any]
    @Binding var dict: NSMutableDictionary
    @State var index: Int
    @State var isAddingToDict: Bool
    @State private var dataTypes = ["Boolean", "Integer", "String", "Array", "Dictionary"]
    @State private var selectedDataType = ""
    @State private var fakeKey = ""
    
    @State var newKey = ""
    @State var newBool = false
    @State var newInt = 0
    @State var newString = ""
    @State var newArray: [Any] = []
    @State var newDict: NSMutableDictionary = NSMutableDictionary()

    var body: some View {
        
        if(isAddingToDict) {
            PlistKeyView(show: true, key: $newKey)
        }
    
        Picker("E", selection: $selectedDataType) {
            ForEach(dataTypes, id: \.self) { dataType in
                Text(dataType)
            }
        }
        .pickerStyle(DefaultPickerStyle())
        
        switch selectedDataType {
        case "Boolean":
            PlistBoolView(key: $fakeKey, bool: $newBool, isInDict: false)
        case "Integer":
            PlistIntView(key: $fakeKey, int: $newInt, isInDict: false)
        case "String":
            PlistStringView(key: $fakeKey, string: $newString, isInDict: false)
        case "Array":
            PlistArrayView(key: $fakeKey, array: $newArray, isInDict: false)
        case "Dictionary":
            PlistDictView(key: $fakeKey, dict: $newDict, isInDict: false)
        default:
            Text("")
        }
        
        Button(action: {
            if(isAddingToDict) {
                setToDict()
            } else {
                setToArray()
            }
        }) {
            Text(NSLocalizedString("CONFIRM", comment: ""))
        }
    }
    
    func setToArray() {
        switch selectedDataType {
        case "Boolean":
            array[index] = newBool
        case "Integer":
            array[index] = newInt
        case "String":
            array[index] = newString
        case "Array":
            array[index] = newArray
        case "Dictionary":
            array[index] = newDict
        default:
            array[index] = "what did you DO to cause this to appear."
        }
    }
    
    func setToDict() {
        switch selectedDataType {
        case "Boolean":
            dict.setObject(newBool, forKey: newKey as NSCopying)
        case "Integer":
            dict.setObject(newInt, forKey: newKey as NSCopying)
        case "String":
            dict.setObject(newString, forKey: newKey as NSCopying)
        case "Array":
            dict.setObject(newArray, forKey: newKey as NSCopying)
        case "Dictionary":
            dict.setObject(newDict, forKey: newKey as NSCopying)
        default:
            dict.setObject("DID THIS HAPPEN", forKey: "HOW" as NSCopying)
        }
    }
}

/*struct PlistEditorView: View {

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
    @State var selectedIndex = 0
    @State var itemAddShow = true

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
            HStack {
                Button(action: {
                    parsedArray.remove(at: selectedIndex)
                }) {
                    Text("Remove item at \(selectedIndex)")
                }
                Button(action: {
                    itemAddShow = true
                }) {
                    Text("Add item after \(selectedIndex)")
                }
            }
            ScrollView {
                ForEach(0..<parsedArray.count, id: \.self) { index in
                    VStack {
                        Text(String(index))
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
                }
                .padding()
            }
            .sheet(isPresented: $arrayNestView) {
                PlistEditorView(filePath: $filePath, fileName: $fileName, isPresented: $arrayNestView, plistDict: $plistDict, plistKey: $plistKey, plistData: $plistData, plistKeyType: $plistKeyType, editOccurred: $editOccurred, keyToSet: $keyToSet, valueToSet: $valueToSet, isNestedView: true)
            }
            .sheet(isPresented: $itemAddShow) {
                //PlistAddView(input: )
                Text("hi")
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
*/
