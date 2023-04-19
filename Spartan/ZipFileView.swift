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
    @State var fullFilePaths: [String] = [""]
    
    //uncompress
    @State var zipPassword: String = ""
    @State var extractFilePath: String = ""
    @State var overwriteFiles = false
    
    //both
    @Binding var filePath: String
    @Binding var zipFileName: String //file to be (un)zipped
    
    var body: some View {
        VStack{
            if(unzip){
                Text("**Uncompress Archive**")
                TextField("Destination directory", text: $extractFilePath, onEditingChanged: { (isEditing) in
                    if !isEditing {
                        if(!(extractFilePath.hasSuffix("/")) && UserDefaults.settings.bool(forKey: "autoComplete")){
                            extractFilePath = extractFilePath + "/"
                        }
                    }
                })
                TextField("Archive password (optional)", text: $zipPassword)
                Button(action: {
                    overwriteFiles.toggle()
                }) {
                    Text("Overwrite Existing Files")
                    Image(systemName: overwriteFiles ? "checkmark.square" : "square")
                }
                Button(action: {
                    uncompressFile(pathToZip: filePath + zipFileName, password: zipPassword, overwrite: overwriteFiles, destination: extractFilePath)
                }) {
                    Text("Confirm")
                }
            } else {
                Text("**Compress Files**")
                TextField("Enter archive name", text: $zipFileName, onEditingChanged: { (isEditing) in
                    if !isEditing{
                        if(!(zipFileName.hasSuffix(".zip")) && UserDefaults.settings.bool(forKey: "autoComplete")){
                            zipFileName = zipFileName + ".zip"
                        }
                    }
                })
                TextField("Enter password to apply (optional)", text: $zipPassword)
        
                Button(action: {
                    compressFiles(pathsToFiles: fullFilePaths, password: zipPassword, destination: filePath + zipFileName)
                }) {
                    Text("Confirm")
                }
            }
        }
        .onAppear {
            extractFilePath = filePath
            print("zip view filenames array: ", fileNames)
            print(filePath)
            while (fullFilePaths.count < fileNames.count){
                fullFilePaths.append("")
            }
            for i in 0..<fileNames.count {
                fullFilePaths[i] = filePath + fileNames[i]
            }
            print(fullFilePaths)
        }
    }
    
    func uncompressFile(pathToZip: String, password: String, overwrite: Bool, destination: String) {
        do {
            try Zip.unzipFile(URL(fileURLWithPath: pathToZip), destination: URL(fileURLWithPath: destination), overwrite: overwrite, password: password, progress: { (progress) -> () in
        print(progress)
    })
        } catch {
            print("Failed to extract file: \(error.localizedDescription)")
        }
    }
    
    func compressFiles(pathsToFiles: [String], password: String, destination: String) {
        do {
            try Zip.zipFiles(paths: stringPathToURLPath(filePaths: pathsToFiles), zipFilePath: URL(fileURLWithPath: destination), password: password, progress: { (progress) -> () in
                print(progress)
            })
        } catch {
            print("Failed to compress files: \(error.localizedDescription)")
        }
    }
    
    func stringPathToURLPath(filePaths: [String]) -> [URL] {
        var urls = [URL]()
        for path in filePaths {
            if let url = URL(string: "file://" + path) {
                urls.append(url)
            } else {
                print("Error: Invalid filepath \(path)")
            }
        }
        return urls
    }
}

