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
    @Binding var isPresenting: Bool
    @State private var matchCase = false
    @State private var shallowSearch = false
    @State private var deepSearch = true
    @State var showResults = false
    @State private var currentlySearching = false
    
    @State private var entireResults: [String] = []
    @State private var filteredResults: [String] = []
    @State private var resultsList: [String] = []
    
    
    var body: some View {
        TextField("Enter file or directory name to search for", text: $searchTerm)
            .disabled(currentlySearching)
        TextField("Enter a directory path to search", text: $directoryToSearch)
            .disabled(currentlySearching)
        HStack{
            Button(action: {
                shallowSearch.toggle()
            }) {
                Text("Search Only This Directory")
                Image(systemName: shallowSearch ? "checkmark.square" : "square")
            }
            .disabled(currentlySearching)
            
            Button(action: {
                shallowSearch.toggle()
            }) {
                Text("Search All Subdirectories")
                Image(systemName: !shallowSearch ? "checkmark.square" : "square")
            }
            .disabled(currentlySearching)
            
            Button(action: {
                matchCase.toggle()
            }) {
                Text("Match Case")
                Image(systemName: matchCase ? "checkmark.square" : "square")
            }
            .disabled(currentlySearching)
        }
        Button(action: {
            currentlySearching = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { //so the loading symbol shows
            //horribly hacky but it works
                resultsList = dirSearch(directoryPath: directoryToSearch, searchTerm: searchTerm, searchType: shallowSearch)
                showResults = true
            }
        }) {
            if(currentlySearching){
                ProgressView()
            } else {
                Text("Confirm")
            }
        }
        .disabled(currentlySearching)
        .sheet(isPresented: $showResults, content: { //search files
            SearchResultsView(resultsList: $resultsList, currentDirectory: $directoryToSearch, showingNest: $showResults, showingOriginal: $isPresenting)
        })
        .onAppear {
            currentlySearching = false
        }
    }
    
    func dirSearch(directoryPath: String, searchTerm: String, searchType: Bool) -> [String] {
        do {
            if(searchType){
                let contents = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
                entireResults = contents.map { file in
                    let filePath = "/" + directoryPath + "/" + file
                    var isDirectory: ObjCBool = false
                    FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
                    return isDirectory.boolValue ? "\(file)/" : file
                }
            } else {
                entireResults = searchFilesystem(atPath: directoryToSearch, searchTerm: searchTerm)
            }
        } catch {
            return ["An error occurred: \(error.localizedDescription)"]
        }
        
        for entireResult in entireResults {
            if (matchCase){
                if (entireResults.contains(searchTerm)){
                    filteredResults.append(entireResult)
                }
            } else {
                if entireResult.range(of: searchTerm, options: .caseInsensitive) != nil {
                    filteredResults.append(entireResult)
                }
            }
        }
        return filteredResults
    }
    
    func searchFilesystem(atPath: String, searchTerm: String) -> [String] {
        let pathURL = URL(fileURLWithPath: atPath, isDirectory: true)
        var foundResults: [String] = []
        if let enumerator = FileManager.default.enumerator(atPath: atPath) {
            for file in enumerator {
                let path = URL(fileURLWithPath: file as! String, relativeTo: pathURL).path
                if(path.contains(searchTerm)) {
                    foundResults.append(path)
                }
            }
        }
        return foundResults
    }
}

struct SearchResultsView: View {

    @Binding var resultsList: [String]
    @Binding var currentDirectory: String
    @Binding var showingNest: Bool
    @Binding var showingOriginal: Bool
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Text("Search Results")
        List(resultsList, id: \.self) { string in
            Button(action: {
                let index = string.lastIndex(of: "/")
                currentDirectory = String(string.prefix(upTo: index!)) + "/"
                showingNest = false
                showingOriginal = false
            }) {
                Text(string)
            }
        }
    }
}
