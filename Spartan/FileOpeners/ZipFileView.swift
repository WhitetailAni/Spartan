//
//  ZipFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/15/23.
//

import SwiftUI
import Zip

struct ZipFileView: View {
    @State var unzip: Bool
    @Binding var isPresented: Bool

    //compress
    var fileNames: [String] //files to be archived
    @State private var fullFilePaths: [String] = [""]
    
    //uncompress
    @State private var zipPassword: String = ""
    @State private var extractFilePath: String = ""
    @State private var overwriteFiles = false
    
    //both
    @Binding var filePath: String
    @Binding var zipFileName: String //file to be (un)zipped
    
    @State private var actionProgress: Double = 0
    @State private var showProgress = false
    
    var body: some View {
        VStack{
            if(unzip){
                Text(NSLocalizedString("UNZIP_TITLE", comment: "- She's my cousin!"))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                TextField(NSLocalizedString("UNZIP_DIR", comment: "- She is?"), text: $extractFilePath, onEditingChanged: { (isEditing) in
                    if !isEditing {
                        if(!(extractFilePath.hasSuffix("/")) && UserDefaults.settings.bool(forKey: "autoComplete")){
                            extractFilePath = extractFilePath + "/"
                        }
                    }
                })
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                TextField(NSLocalizedString("UNZIP_PASSWORD", comment: "- Yes, we're all cousins.") + NSLocalizedString("OPTIONAL", comment: "- Right. You're right."), text: $zipPassword)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                Button(action: {
                    overwriteFiles.toggle()
                }) {
                    Text(NSLocalizedString("UNZIP_OVERWRITE", comment: "- At Honex, we constantly strive"))
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                    Image(systemName: overwriteFiles ? "checkmark.square" : "square")
                }
                Button(action: {
                    uncompressFile(pathToZip: filePath + zipFileName, password: zipPassword, overwrite: overwriteFiles, destination: extractFilePath)
                }) {
                    Text(NSLocalizedString("CONFIRM", comment: "to improve every aspect of bee existence."))
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
            } else {
                Text(NSLocalizedString("ZIP_TITLE", comment: "These bees are stress-testing a new helmet technology."))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                TextField(NSLocalizedString("ZIP_FILENAME", comment: "- What do you think he makes?"), text: $zipFileName, onEditingChanged: { (isEditing) in
                    if !isEditing{
                        if(!(zipFileName.hasSuffix(".zip")) && UserDefaults.settings.bool(forKey: "autoComplete")){
                            zipFileName = zipFileName + ".zip"
                        }
                    }
                })
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                TextField(NSLocalizedString("ZIP_PASSWORD", comment: "Here we have our latest advancement, the Krelman.") + NSLocalizedString("OPTIONAL", comment: ""), text: $zipPassword)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                
                if(showProgress) {
                    UIKitProgressView(value: $actionProgress, total: 100)
                }
        
                Button(action: {
                    compressFiles(pathsToFiles: fullFilePaths, password: zipPassword, destination: filePath + zipFileName)
                    showProgress = true
                }) {
                    Text(NSLocalizedString("CONFIRM", comment: "- What does that do?"))
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
                
            }
        }
        .onAppear {
            extractFilePath = filePath
            while (fullFilePaths.count < fileNames.count){
                fullFilePaths.append("")
            }
            for i in 0..<fileNames.count {
                fullFilePaths[i] = filePath + fileNames[i]
            }
        }
    }
    
    func uncompressFile(pathToZip: String, password: String, overwrite: Bool, destination: String) {
        do {
            try Zip.unzipFile(URL(fileURLWithPath: pathToZip), destination: URL(fileURLWithPath: destination), overwrite: overwrite, password: password, progress: { (progress) -> () in
            print(progress)
            actionProgress = progress
    })
        } catch {
            print("Failed to extract file: \(error.localizedDescription)")
        }
    }
    
    func compressFiles(pathsToFiles: [String], password: String, destination: String) {
        do {
            try Zip.zipFiles(paths: stringPathToURLPath(filePaths: pathsToFiles), zipFilePath: URL(fileURLWithPath: destination), password: password, progress: { (progress) -> () in
                print(progress)
                actionProgress = progress
            })
        } catch {
            print("Failed to compress files: \(error.localizedDescription)")
        }
    }
    
    func stringPathToURLPath(filePaths: [String]) -> [URL] {
        var urls = [URL]()
        for path in filePaths {
            if let url = URL(string: "file://" + path) { //weird url init becuse otherwise it complains about optional bindings
                urls.append(url)
            } else {
                print("Error: Invalid filepath \(path)")
            }
        }
        return urls
    }
}
