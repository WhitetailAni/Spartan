//
//  PlistViewOlder.swift
//  Spartan
//
//  Created by RealKGB on 8/21/23.
//

import SwiftUI
import Foundation

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
