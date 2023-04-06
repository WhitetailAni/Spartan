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
    
    @State private var renameFileShow = false
    @State var renameFileCurrentPath: String = ""
    @State var renameFileCurrentName: String = ""
    
    @State private var searchShow = false
    @State private var createDirectoryShow = false
    @State private var createFileShow = false
    @State private var favoritesShow = false
    @State private var settingsShow = false
    
    @State private var moveFileShow = false
    @State var moveFileCurrentPath: String = ""
    @State var moveFileCurrentName: String = ""
    
    @State private var copyFileShow = false
    @State var copyFileCurrentPath: String = ""
    @State var copyFileCurrentName: String = ""
    
    @State private var videoPlayerShow = false
    @State var videoPlayerPath: String = ""
    
    @State private var audioPlayerShow = false
    @State var audioPlayerPath: String = ""
    
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
                topBar
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
                            } else if (file.hasSuffix("aifc") || file.hasSuffix("m4r") || file.hasSuffix("wav") || file.hasSuffix("flac") || file.hasSuffix("m2a") || file.hasSuffix("aac") || file.hasSuffix("mpa") || file.hasSuffix("xhe") || file.hasSuffix("aiff") || file.hasSuffix("amr") || file.hasSuffix("caf") || file.hasSuffix("m4a") || file.hasSuffix("m4r") || file.hasSuffix("m4b") || file.hasSuffix("mp1") || file.hasSuffix("m1a") || file.hasSuffix("aax") || file.hasSuffix("mp2") || file.hasSuffix("w64") || file.hasSuffix("m4r") || file.hasSuffix("aa") || file.hasSuffix("mp3") || file.hasSuffix("au") || file.hasSuffix("eac3") || file.hasSuffix("ac3") || file.hasSuffix("m4p") || file.hasSuffix("loas")) {
                                audioPlayerShow = true
                                audioPlayerPath = directory + file
                            } else if (file.hasSuffix("3gp") || file.hasSuffix("3g2") || file.hasSuffix("avi") || file.hasSuffix("mov") || file.hasSuffix("m4v") || file.hasSuffix("mp4")){
                                videoPlayerShow = true
                                videoPlayerPath = directory + file
                            } else {
                                selectedFile = FileInfo(name: file, id: UUID())
                            }
                        }) {
                            HStack {
                                if (file.hasSuffix("/")) {
                                    if (isDirectoryEmpty(atPath: directory + file) == 1){
                                        Image(systemName: "folder")
                                    } else if (isDirectoryEmpty(atPath: directory + file) == 0){
                                        Image(systemName: "folder.fill")
                                    } else {
                                        Image(systemName: "folder.badge.questionmark")
                                    }
                                    Text(substring(str: file, startIndex: file.index(file.startIndex, offsetBy: 0), endIndex: file.index(file.endIndex, offsetBy: -1)))
                                } else if (FileManager.default.isExecutableFile(atPath: directory + file)){
                                    Image(systemName: "terminal")
                                    Text(file)
                                } else if (file.hasSuffix("aifc") || file.hasSuffix("m4r") || file.hasSuffix("wav") || file.hasSuffix("flac") || file.hasSuffix("m2a") || file.hasSuffix("aac") || file.hasSuffix("mpa") || file.hasSuffix("xhe") || file.hasSuffix("aiff") || file.hasSuffix("amr") || file.hasSuffix("caf") || file.hasSuffix("m4a") || file.hasSuffix("m4r") || file.hasSuffix("m4b") || file.hasSuffix("mp1") || file.hasSuffix("m1a") || file.hasSuffix("aax") || file.hasSuffix("mp2") || file.hasSuffix("w64") || file.hasSuffix("m4r") || file.hasSuffix("aa") || file.hasSuffix("mp3") || file.hasSuffix("au") || file.hasSuffix("eac3") || file.hasSuffix("ac3") || file.hasSuffix("m4p") || file.hasSuffix("loas")) {
                                    Image(systemName: "waveform.circle")
                                    Text(file)
                                } else if (file.hasSuffix("3gp") || file.hasSuffix("3g2") || file.hasSuffix("avi") || file.hasSuffix("mov") || file.hasSuffix("m4v") || file.hasSuffix("mp4")){
                                    Image(systemName: "video")
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
                                renameFileCurrentPath = directory
                                renameFileCurrentName = file
                                renameFileShow = true
                            }) {
                                Text("Rename")
                            }
                            
                            if(directory == "/var/mobile/Media/.Trash/"){
                                Button(action: {
                                    deleteFile(atPath: directory + file)
                                    updateFiles()
                                }) {
                                    Text("Delete")
                                }
                            } else {
                                Button(action: {
                                    moveFile(path: directory + file, newPath: ("/var/mobile/Media/.Trash/" + file))
                                    updateFiles()
                                }) {
                                    Text("Move to Trash")
                                }
                            }
                            
                            Button(action: {
                                moveFileCurrentPath = directory
                                moveFileCurrentName = file
                                moveFileShow = true
                            }) {
                                Text("Move To")
                            }
                            
                            Button(action: {
                                copyFileCurrentPath = directory
                                copyFileCurrentName = file
                                copyFileShow = true
                            }) {
                                Text("Copy To")
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
                .sheet(isPresented: $searchShow, content: { //search files
                    SearchView()
                })
                .sheet(isPresented: $createDirectoryShow, content: { //create dir
                    CreateDirectoryView(directoryPath: directory, isPresented: $createDirectoryShow)
                })
                .sheet(isPresented: $createFileShow, content: { //create file
                    CreateFileView(filePath: directory, isPresented: $createFileShow)
                })
                .sheet(isPresented: $favoritesShow, content: {
                    FavoritesView()
                })
                .sheet(isPresented: $settingsShow, content: {
                    SettingsView()
                })
                .sheet(isPresented: $renameFileShow, content: {
                    RenameFileView(fileName: $renameFileCurrentName, filePath: $renameFileCurrentPath, isPresented: $renameFileShow)
                })
                .sheet(isPresented: $moveFileShow, content: {
                    MoveFileView(fileName: $moveFileCurrentName, filePath: $moveFileCurrentPath, isPresented: $moveFileShow)
                })
                .sheet(isPresented: $copyFileShow, content: {
                    CopyFileView(fileName: $copyFileCurrentName, filePath: $copyFileCurrentPath, isPresented: $copyFileShow)
                })
                .sheet(isPresented: $videoPlayerShow, content: {
                    VideoPlayerView(videoPath: $videoPlayerPath)
                })
                .sheet(isPresented: $audioPlayerShow, content: {
                    AudioPlayerView(audioPath: $audioPlayerPath)
                })
            }
        }
    }
    
    var topBar: some View {
        HStack {
                    Button(action: {
                        searchShow = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .frame(width:50, height:50)
                    }
                
                    Button(action: { //new file
                        createFileShow = true
                    }) {
                        Image(systemName: "doc.badge.plus")
                            .frame(width:50, height:50)
                    }
                    
                    Button(action: { //new directory
                        createDirectoryShow = true
                    }) {
                        Image(systemName: "folder.badge.plus")
                            .frame(width:50, height:50)
                    }
                    
                    Button(action: { //favorites
                        favoritesShow = true
                    }) {
                        Image(systemName: "star")
                            .frame(width:50, height:50)
                    }
                    
                    Button(action: { //settings
                        settingsShow = true
                    }) {
                        Image(systemName: "gear")
                            .frame(width:50, height:50)
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
    
    func isDirectoryEmpty(atPath path: String) -> Int {
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: path)
            if(files.isEmpty){
                return 1
            } else {
                return 0
            }
            
        } catch {
            print("Error checking directory contents: \(error.localizedDescription)")
            return 2
        }
    }
    
    func moveFile(path: String, newPath: String) {
        do {
            try FileManager.default.moveItem(atPath: path, toPath: newPath)
        } catch {
            print("Failed to move file: \(error.localizedDescription)")
        }
    }
}

struct FileInfo: Identifiable {
    let name: String
    let id: UUID
}
