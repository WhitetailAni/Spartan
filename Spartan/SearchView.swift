//
//  SearchView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI
import Foundation

struct SearchView: View {

    @State var searchTerm: String = ""
    @Binding var directoryToSearch: String
    @State var matchCase = false
    @State var shallowSearch = false
    @State var deepSearch = true
    @State var showResults = false
    
    var body: some View {
        TextField("Enter file or directory name to search for", text: $searchTerm)
        TextField("Enter a directory path to search", text: $directoryToSearch)
        HStack{
            Button(action: {
                if(shallowSearch){
                    shallowSearch = false
                } else {
                    shallowSearch = true
                }
                if(deepSearch){
                    deepSearch = false
                }
            }) {
                Text("Search Only This Directory")
                Image(systemName: shallowSearch ? "checkmark.square" : "square")
            }
            Button(action: {
                if(deepSearch){
                    deepSearch = false
                } else {
                    deepSearch = true
                }
                if(shallowSearch){
                    shallowSearch = false
                }
            }) {
                Text("Search All Directories")
                Image(systemName: deepSearch ? "checkmark.square" : "square")
            }
            Button(action: {
                if(matchCase){
                    matchCase = false
                } else {
                    matchCase = true
                }
            }) {
                Text("Match Case")
                Image(systemName: matchCase ? "checkmark.square" : "square")
            }
        }
        Button(action: {
            showResults = true
        }) {
            Text("Confirm")
        }
        .sheet(isPresented: $showResults, content: { //search files
            SearchResultsView(resultsList: dirSearch(directoryPath: directoryToSearch, searchTerm: searchTerm, searchType: shallowSearch))
        })
    }
    
    func dirSearch(directoryPath: String, searchTerm: String, searchType: Bool) -> [String] {
        @State var entireResults: [String] = [""]
        @State var filteredResults: [String] = [""]
    
        print("uhh")
    
        do {
            if(searchType){
                print(try FileManager.default.contentsOfDirectory(atPath: directoryPath))
            } else {
                print(directoryEnumeratorToStringArray(FileManager.default.enumerator(atPath: directoryPath)!))
            }
        } catch {
            return ["An error occurred: \(error.localizedDescription)"]
        }
        
        print(directoryToSearch)
        print(searchTerm)
        print(entireResults)
        
        for entireResult in entireResults {
            @State var i: Int = 0
            print("made it to loop")
            if (matchCase){
                print("matchcase")
                if (entireResult.contains(searchTerm)){
                    print("matchcase SUCCESS!")
                    print(entireResult, " = ", searchTerm, "?")
                    filteredResults[i] = entireResult
                }
            } else {
                print("anycase")
                if (entireResult.localizedCaseInsensitiveContains(searchTerm)){
                    print("anycase SUCCESS!")
                    print(entireResult, " = ", searchTerm, "?")
                    filteredResults[i] = entireResult
                }
            }
            print("made it past loop")
            i += 1
        }
        return filteredResults
    }
    func directoryEnumeratorToStringArray(_ enumerator: FileManager.DirectoryEnumerator) -> [String] {
        var array = [String]()
        while let fileURL = enumerator.nextObject() as? URL {
            if fileURL.isFileURL {
                array.append(fileURL.path)
            }
        }
        return array
    }
}

struct SearchResultsView: View {

    @State var resultsList: [String]

    var body: some View {
        Text("filter results")
        List(resultsList, id: \.self) { string in
            Text(string)
        }
    }
}


struct Checkbox: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(configuration.isOn ? .green : .gray)
            configuration.label
        }
    }
}
