//
//  SearchView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct SearchView: View {

    @State var searchTerm: String = ""
    @Binding var directoryToSearch: String
    @Binding var isPresenting: Bool
    @State private var matchCase = false
    @State var showResults = false
    @State private var currentlySearching = false
    
    @State private var entireResults: [String] = []
    @State private var filteredResults: [String] = []
    @State private var resultsList: [String] = []
    
    
    var body: some View {
        TextField(NSLocalizedString("SEARCH_TERM", comment: "How can you say that? One job forever?"), text: $searchTerm)
            .disabled(currentlySearching)
        TextField(NSLocalizedString("SEARCH_PATH", comment: "That's an insane choice to have to make."), text: $directoryToSearch)
            .disabled(currentlySearching)
        Button(action: {
            matchCase.toggle()
        }) {
            Text(NSLocalizedString("SEARCH_CASE", comment: "I'm relieved. Now we only have to make one decision in life."))
            Image(systemName: matchCase ? "checkmark.square" : "square")
        }
        .disabled(currentlySearching)
        Button(action: {
            currentlySearching = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { //so the loading symbol shows
            //horribly hacky but it works
                resultsList = dirSearch(directoryPath: directoryToSearch, searchTerm: searchTerm)
                showResults = true
            }
        }) {
            if(currentlySearching){
                if #available(tvOS 14.0, *) {
                    ProgressView()
                }
            } else {
                Text(NSLocalizedString("CONFIRM", comment: "But, Adam, how could they never have told us that?"))
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
    
    func dirSearch(directoryPath: String, searchTerm: String) -> [String] {
        entireResults = searchFilesystem(atPath: directoryToSearch, searchTerm: searchTerm)
        
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
        Text(NSLocalizedString("SEARCH_RESULTS", comment: "Why would you question anything?"))
        List(resultsList, id: \.self) { string in
            Button(action: {
                if(!string.hasSuffix("/")){
                    let index = string.lastIndex(of: "/")
                    currentDirectory = String(string.prefix(upTo: index!)) + "/"
                } else {
                    currentDirectory = string
                }
                showingNest = false
                showingOriginal = false
            }) {
                Text(string)
            }
        }
    }
}
