//
//  PlistViewOld.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI
import Foundation

/*struct PlistView: View {
    
    @Binding var filePath: String
    @State var fileName: String
    @Binding var firstTime: Bool
    @State var isRootDict: Bool
    @State var isInDict: Bool
    
    @State var success = false
    @State var fail = false
    
    @Binding var plistDict: [String: Any]
    
    var body: some View {
        if isRootDict {
            Text(UserDefaults.settings.bool(forKey: "descriptiveTitles") ? filePath + fileName : fileName)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                .font(.system(size: 40))
                .multilineTextAlignment(.center)
                .padding(-10)
        } else {
            if isInDict {
                TextField(NSLocalizedString("PLIST_KEY", comment: ""), text: $filePath)
            }
        }
            
        List(Array(plistDict.keys.sorted()), id: \.self) { key in
            let value = plistDict[key] as Any
            
            Button(action: {
            }) {
                switch value {
                case is Bool:
                    Text("\(key): \(String(describing: value as! Bool)) (Boolean)")
                case is Int:
                    Text("\(key): \(String(describing: value as! Int)) (Integer)")
                case is String:
                    Text("\(key): \(value as! String) (String)")
                case is [Any]:
                    Text("\(key): \(String(describing: value as! [Any])) (Array)")
                case is [String: Any]:
                    Text("\(key): \(String(describing: value as! [String: Any])) (Dictionary)")
                case is Data:
                    Text("\(key): \(String(describing: value as! Data)) (Data)")
                default:
                    Text("An unknown data type was detected.")
                }
            }
        }
        .onAppear {
            if !firstTime {
                let data = FileManager.default.contents(atPath: filePath + fileName)
                let backup = ["Error": "The file is corrupted or not a plist file. Ensure the file is the proper format and then try again."]
                do {
                    plistDict = try PropertyListSerialization.propertyList(from: data!, options: [], format: nil) as? [String: Any] ?? backup
                } catch {
                    plistDict = backup
                }
                firstTime = true
            }
            print(plistDict)
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

struct PlistKeyView: View {
    @State var show: Bool
    @Binding var key: String
    
    var body: some View {
        if(show) {
            TextField(NSLocalizedString("PLIST_KEY", comment: ""), text: $key)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
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
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
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
    @State private var fakeDict: [String: Any] = [:]
    
    @State var garbage = false
    
    var body: some View {
        HStack {
            Button(action: {
                addViewShow = true
            }) {
                Text(NSLocalizedString("PLISTARR_ADD", comment: "") + String(topBarIndex))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
            Button(action: {
                mutableArray.remove(at: topBarIndex)
            }) {
                Text(NSLocalizedString("PLISTARR_REMOVE", comment: "") + String(topBarIndex))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
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
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    Button(action: {
                        selectedIndex = 0
                        showSheet = true
                    }) {
                        Text(mutableArray[index] as! String)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $showSheet, content: {
            switch mutableArray[selectedIndex] {
            case is Bool:
                PlistBoolView(key: $fakeKey, bool: $mutableArray[selectedIndex] as! Binding<Bool>, isInDict: false)
            case is Int:
                PlistIntView(key: $fakeKey, int: $mutableArray[selectedIndex] as! Binding<Int>, isInDict: false)
            case is String:
                PlistStringView(key: $fakeKey, string: $mutableArray[selectedIndex] as! Binding<String>, isInDict: false)
            case is [Any]:
                PlistArrayView(key: $fakeKey, array: $mutableArray[selectedIndex] as! Binding<[Any]>, isInDict: false)
            case is [String: Any]:
                PlistView(filePath: $fakeKey, fileName: fakeKey, firstTime: $garbage, isRootDict: false, isInDict: false, plistDict: $mutableArray[selectedIndex] as! Binding<[String: Any]>)
            default:
                Text(NSLocalizedString("PLIST_UNKNOWNTYPE", comment: ""))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        })
        .sheet(isPresented: $addViewShow, content: {
            PlistAddView(array: $mutableArray, dict: $fakeDict, index: topBarIndex, isAddingToDict: false)
        })
    }
}



struct PlistAddView: View {

    @Binding var array: [Any]
    @Binding var dict: [String: Any]
    @State var index: Int
    @State var isAddingToDict: Bool
    @State private var dataTypes = ["Boolean", "Integer", "String", "Array", "Dictionary", "Data"]
    @State private var selectedDataType = ""
    @State private var fakeKey = ""
    
    @State var newKey = ""
    @State var newBool = false
    @State var newInt = 0
    @State var newString = ""
    @State var newArray: [Any] = []
    @State var newDict: [String: Any] = [:]
    @State var newData: Data = Data()
    
    @State var garbage = false

    var body: some View {
        
        if(isAddingToDict) {
            PlistKeyView(show: true, key: $newKey)
        }
    
        Picker("E", selection: $selectedDataType) {
            ForEach(dataTypes, id: \.self) { dataType in
                Text(dataType)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
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
            PlistView(filePath: $fakeKey, fileName: fakeKey, firstTime: $garbage, isRootDict: garbage, isInDict: false, plistDict: $newDict)
        case "Data":
            PlistDataView(key: $fakeKey, data: $newData, isInDict: false)
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
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
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
        case "Data":
            array[index] = newData
        default:
            array[index] = "what did you DO to cause this to appear."
        }
    }
    
    func setToDict() {
        switch selectedDataType {
        case "Boolean":
            dict[newKey] = newBool
        case "Integer":
            dict[newKey] = newInt
        case "String":
            dict[newKey] = newString
        case "Array":
            dict[newKey] = newArray
        case "Dictionary":
            dict[newKey] = newDict
        case "Data":
            dict[newKey] = newData
        default:
            dict["HOW"] = "DID THIS HAPPEN"
        }
    }
}

struct PlistDataView: View {
    
    @Binding var key: String
    @Binding var data: Data
    @State var isInDict: Bool
    
    var body: some View {
        PlistKeyView(show: isInDict, key: $key)
        TextField(NSLocalizedString("PLIST_DATA", comment: ""), text: Binding(
            get: {
                String(data: data, encoding: .utf8) ?? ""
            },
            set: { newValue in
                if let newData = newValue.data(using: .utf8) {
                    data = newData
                }
            }
        ))
    }
}*/
