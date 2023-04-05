//
//  ContentView.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
import UIKit
import Foundation

struct ContentView: View {
    @State var directory: String
    @State private var files: [String] = []
    @State private var selectedFile: FileInfo?
    @State private var textSuccess = false
    @State private var fileInfo: String = ""
    @State var permissionDenied = false
    @State var fileInfoShow = false
    
    @State private var renameFileName = ""
    @State private var renameFileShow = false
    @State private var renameFilePath: String = ""
    
    @State private var createDirectoryShow = false
    @State private var mkdirName: String = ""
    
    @State private var createFileShow = false
    
    @State private var favoritesShow = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                HStack { //input directory + refresh
                    TextField("Input directory", text: $directory)
                    Button(action: {
                        updateFiles()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                HStack { //copy, paste, create, etc buttons
                    /*Button(action: { //copy
                        //i dont know how to do this
                    }) {
                        Image(systemName: "doc.on.doc")
                    }
                    
                    Button(action: { //paste
                        //or this
                        //could maybe add it as a context menu action? copy to?
                    }) {
                        Image(systemName: "doc.on.clipboard")
                    }*/
                    
                    Button(action: { //new directory
                        createDirectoryShow = true
                    }) {
                        Image(systemName: "folder.badge.plus")
                            .frame(width:50, height:50)
                    }
                    
                    Button(action: { //new file
                        createFileShow = true
                    }) {
                        Image(systemName: "doc.badge.plus")
                            .frame(width:50, height:50)
                    }
                    
                    Button(action: { //favorites
                        favoritesShow = true
                    }) {
                        Image(systemName: "star")
                            .frame(width:50, height:50)
                    }
                }
                List { //directory contents view
                    Button(action: {
                        goBack()
                    }) {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.backward")
                            Text("..")
                        }
                    }
                    ForEach(files, id: \.self) { file in
                        Button(action: {
                            if file.hasSuffix("/") {
                                directory += file
                                updateFiles()
                                print(directory)
                            } else {
                                selectedFile = FileInfo(name: file, id: UUID())
                            }
                        }) {
                            HStack {
                                if (file.hasSuffix("/")) {
                                    if (isDirectoryEmpty(atPath: directory + file)){
                                        Image(systemName: "folder")
                                    } else {
                                        Image(systemName: "folder.fill")
                                    }
                                    Text(substring(str: file, startIndex: file.index(file.startIndex, offsetBy: 0), endIndex: file.index(file.endIndex, offsetBy: -1)))
                                } else if (FileManager.default.isExecutableFile(atPath: directory + file)){
                                    Image(systemName: "terminal")
                                    Text(file)
                                } else {
                                    Image(systemName: "doc")
                                    Text(file)
                                }
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                fileInfoShow = true
                                fileInfo = getFileInfo(forFileAtPath: directory + file)
                            }) {
                                Text("Info")
                            }
                            
                            Button(action: {
                                renameFilePath = file
                                renameFileShow = true
                                print(renameFilePath)
                            }) {
                                Text("Rename")
                            }
                            
                            Button(action: {
                                deleteFile(atPath: directory + file)
                                updateFiles()
                            }) {
                                Text("Delete")
                            }
                            Button(action: { }) { //if you have an empty button it dismisses a context menu??
                                Text("Dismiss")
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    updateFiles()
                }
                .alert(isPresented: $permissionDenied) { //permissions fail!
                    Alert(
                        title: Text("Permission denied"),
                        dismissButton: .default(Text("Dismiss"))
                    )
                }
                .alert(isPresented: $fileInfoShow) { //file info
                    Alert(
                        title: Text("File info"),
                        message: Text(fileInfo),
                        dismissButton: .default(Text("Dismiss"))
                    )
                }
                .sheet(item: $selectedFile) { file in //text editor
                    if(textSuccess){
                        Text("**Text Viewer**")
                    }
                    ScrollView{
                        Text(readTextFile(path: directory + file.name))
                    }
                }
                .sheet(isPresented: $createDirectoryShow, content: { //create dir
                    CreateDirectoryView(directoryName: $mkdirName, directoryPath: directory, isPresented: $createDirectoryShow)
                })
                .sheet(isPresented: $createFileShow, content: { //create file
                    CreateFileView(fileName: $mkdirName, filePath: directory, isPresented: $createFileShow)
                })
                .sheet(isPresented: $favoritesShow, content: {
                    FavoritesView()
                })
                .sheet(isPresented: $renameFileShow, content: {
                    RenameFileView(fileName: $renameFileName, filePath: (directory + renameFilePath), isPresented: $renameFileShow)
                })
            }
        }
    }

    func updateFiles() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
            files = contents.map { file in
                let filePath = "/" + directory + "/" + file
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
                return isDirectory.boolValue ? "\(file)/" : file
            }
        } catch {
            print(error)
            if(substring(str: error.localizedDescription, startIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: -33), endIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: 0)) == "don’t have permission to view it."){
                permissionDenied = true
                goBack()
            }
        }
    }
    
    func readTextFile(path: String) -> String {
        do {
            let fileSelected = try String(contentsOfFile: path, encoding: .utf8)
            textSuccess = true
            return fileSelected
        } catch {
            print(error.localizedDescription)
            return error.localizedDescription
        }
    }
    
    func goBack() {
        guard directory != "/" else { return }
        var components = directory.split(separator: "/")
    
        if components.count > 1 {
            components.removeLast()
            directory = "/" + components.joined(separator: "/") + "/"
        } else if components.count == 1 {
            directory = "/"
        }
        updateFiles()
    }
    
    func substring(str: String, startIndex: String.Index, endIndex: String.Index) -> Substring {
        let range: Range = startIndex..<endIndex
        return str[range]
    }
    
    func deleteFile(atPath path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("Failed to delete file: \(error.localizedDescription)")
        }
    }
    
    func getFileInfo(forFileAtPath path: String) -> String {
        let fileManager = FileManager.default
    
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path)
    
            let creationDate = attributes[.creationDate] as? Date ?? Date.distantPast
            let modificationDate = attributes[.modificationDate] as? Date ?? Date.distantPast
            
            let fileSize = attributes[.size] as? Int ?? 0
            
            @State var fileOwner: String = ((attributes[.ownerAccountName] as? String)!)
            
            let fileOwnerID = attributes[.groupOwnerAccountID] as? Int ?? 0
            let filePerms = String(format: "%03d", attributes[.posixPermissions] as? Int ?? "000")
            

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            let fileInfoString = """
            File path: \(path)
            File size: \(ByteCountFormatter().string(fromByteCount: Int64(fileSize)))
            Creation date: \(dateFormatter.string(from: creationDate))
            Modification date: \(dateFormatter.string(from: modificationDate))
            File owner: \(fileOwner)
            File owner ID: \(fileOwnerID)
            File permissions: \(filePerms)
            """

            return fileInfoString
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
    
    func isDirectoryEmpty(atPath path: String) -> Bool {
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: path)
            return files.isEmpty
        } catch {
            print("Error checking directory contents: \(error.localizedDescription)")
            return false
        }
    }
}

struct creditsView: View {
    var body: some View {
        Text("credits")
    }
}

struct FileInfo: Identifiable {
    let name: String
    let id: UUID
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(directory: "/")
    }
}

struct CreateDirectoryView: View {
    @Binding var directoryName: String
    @State var directoryPath: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            TextField("Enter directory name", text: $directoryName)
            Button("Confirm") {
                do {
                    try createDirectoryAtPath(path: directoryPath, directoryName: directoryName)
                    print("Directory created successfully")
                    isPresented = false
                    directoryName = ""
                } catch {
                    print("Failed to create directory: \(error.localizedDescription)")
                }
            }
            .padding()
        }
        .padding()
    }
    
    func createDirectoryAtPath(path: String, directoryName: String) throws {
        let fileManager = FileManager.default
        let directoryPath = (path as NSString).appendingPathComponent(directoryName)
        try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
    }
}

struct RenameFileView: View {
    @Binding var fileName: String
    @State var filePath: String
    @Binding var isPresented: Bool
    
    var body: some View {
        TextField("Enter new file name", text: $fileName)
        Button("test"){
            print(fileName)
            print(filePath)
        }
        Button("Confirm") {
            renameFile(path: filePath, fileName: fileName)
            print("File renamed successfully")
            fileName = ""
            //isPresented = false
        }
    }
    
    func renameFile(path: String, fileName: String) {
        
        do {
            try FileManager.default.moveItem(atPath: path, toPath: fileName)
        } catch {
            print("Failed to rename file: \(error.localizedDescription)")
        }
    }
}

struct CreateFileView: View {
    @Binding var fileName: String
    @State var filePath: String
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            TextField("Enter file name", text: $fileName)
            Button("Confirm") {
                do {
                    try createFileAtPath(path: filePath, fileName: fileName)
                    print("File created successfully")
                    fileName = ""
                    isPresented = false
                } catch {
                    print("Failed to create file: \(error.localizedDescription)")
                }
            }
            .padding()
        }
        .padding()
    }
    
    func createFileAtPath(path: String, fileName: String) throws {
        let fileManager = FileManager.default
        let filePath = (path as NSString).appendingPathComponent(fileName)
        fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
    }
}

struct FavoritesView: View {
    var body: some View {
        Text("**Favorites**")
        //for loop through each entry in the array (will need to store in some permanent place)
        //pressing each one will change directory to that, then updateFiles()
    }
}
