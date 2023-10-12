//
//  SearchView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//  I legitimately have no idea how this works. I have a vague memory of creating it but it's a big blur because I believe I had COVID at the time? It works - I know that - but this is the first time I've looked at the code since like June or July
//

import SwiftUI

struct SearchView: View {

    @State var searchTerm: String = ""
    @Binding var directory: String
    @State var directoryToSearch = ""
    @Binding var isPresenting: Bool
    @State private var matchCase = false
    @State var showResults = false
    @State private var currentlySearching = false
    
    @Binding var selectedFile: String
    @Binding var didSearch: Bool
    
    @State private var entireResults: [String] = []
    @State private var filteredResults: [String] = []
    @State private var resultsList: [String] = []
    
    
    var body: some View {
        if (!showResults) {
            TextField(NSLocalizedString("SEARCH_TERM", comment: "How can you say that? One job forever?"), text: $searchTerm)
                .disabled(currentlySearching)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            TextField(NSLocalizedString("SEARCH_PATH", comment: "That's an insane choice to have to make."), text: $directoryToSearch)
                .disabled(currentlySearching)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                .onAppear {
                    directoryToSearch = directory
                }
            Button(action: {
                matchCase.toggle()
            }) {
                Text(NSLocalizedString("SEARCH_CASE", comment: "I'm relieved. Now we only have to make one decision in life."))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                Image(systemName: matchCase ? "checkmark.square" : "square")
            }
            .disabled(currentlySearching)
            
            Button(action: {
                withAnimation {
                    currentlySearching = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { //so the loading symbol shows
                //horribly hacky but it works
                    resultsList = dirSearch(directoryPath: directoryToSearch, searchTerm: searchTerm)
                    showResults = true
                }
            }) {
                if #available(tvOS 14.0, *) {
                    if (currentlySearching) {
                        ProgressView()
                    } else {
                        Text(NSLocalizedString("CONFIRM", comment: "But, Adam, how could they never have told us that?"))
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                } else {
                    Text(NSLocalizedString("CONFIRM", comment: "But, Adam, how could they never have told us that?"))
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
            }
            .disabled(currentlySearching)
            .onAppear {
                currentlySearching = false
            }
        } else {
            Text(NSLocalizedString("SEARCH_RESULTS", comment: "Why would you question anything?"))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
            List(resultsList, id: \.self) { result in
                Button(action: {
                    selectedFile = result
                    isPresenting = false
                }) {
                    Text(result)
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
            }
            .onAppear {
                didSearch = true
                for i in 0..<resultsList.count {
                    var isDirectory: ObjCBool = false
                    FileManager.default.fileExists(atPath: resultsList[i], isDirectory: &isDirectory)
                    if(isDirectory.boolValue) {
                        resultsList[i].append("/")
                    }
                }
            }
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
