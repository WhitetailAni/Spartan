//
//  ContentView.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
import UIKit
import Foundation
import MobileCoreServices
import AVKit

struct ContentView: View {
    @State var directory: String
    @State private var files: [String] = []
    @State private var selectedFile: FileInfo?
    @State private var textSuccess = false
    @State private var fileInfo: String = ""
    @State var permissionDenied = false
    @State var deleteOverride = false
    
    @State var multiSelect = false
    @State var allWereSelected = false
    @State var multiSelectFiles: [String] = []
    @State var fileWasSelected: [Bool] = [false]
    
    @State var fileInfoShow = false
    
    @State var newViewFilePath: String = ""
    @State var newViewArrayNames: [String] = [""]
    @State var newViewFileName: String = ""
    
    @State private var renameFileShow = false
    @State var renameFileCurrentName: String = ""
    @State var renameFileNewName: String = ""
    
    @State private var sidebarShow = false
    
    @State private var searchShow = false
    @State private var createDirectoryShow = false
    @State private var createFileShow = false
    @State private var favoritesShow = false
    @State private var settingsShow = false
    
    @State private var moveFileShow = false
    @State private var copyFileShow = false
    
    @State private var audioPlayerShow = false
    @State private var videoPlayerShow = false
    @State var globalAVPlayer = AVPlayer()
    @State var isGlobalAVPlayerPlaying = false
    @State var callback = true
    
    @State private var imageShow = false
    @State private var plistShow = false
    @State private var textShow = false
    @State private var spawnShow = false
    
    @State private var zipFileShow = false
    @State private var uncompressZip = false
    
    @State private var addToFavoritesShow = false
    @State private var addToFavoritesDisplayName: String = ""
    
    @State var blankString: [String] = [""]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack { //input directory + refresh
                    TextField("Input directory", text: $directory, onCommit: {
                        updateFiles()
                    })
                    Button(action: {
                        updateFiles()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                HStack {
                    topBarOffset
                        .frame(alignment: .leading)
                    topBar
                        .frame(alignment: .center)
                    freeSpace
                        .frame(alignment: .trailing)
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
                    ForEach(files.indices, id: \.self) { index in
                        Button(action: {
                            if (multiSelect) {
                                if(fileWasSelected[index]){
                                    let searchedIndex = multiSelectFiles.firstIndex(of: files[index])
                                    multiSelectFiles.remove(at: searchedIndex!)
                                    fileWasSelected[index] = false
                                    print(multiSelectFiles)
                                } else {
                                    fileWasSelected[index] = true
                                    multiSelectFiles.append(files[index])
                                    print(multiSelectFiles)
                                }
                            } else {
                                multiSelect = false
                                if (yandereDevFileType(file: (directory + files[index])) == 0) {
                                    directory = directory + files[index]
                                    updateFiles()
                                    print(directory)
                                } else if (yandereDevFileType(file: (directory + files[index])) == 1) {
                                    audioPlayerShow = true
                                    callback = true
                                    newViewFilePath = directory + files[index]
                                    newViewFileName = files[index]
                                } else if (yandereDevFileType(file: (directory + files[index])) == 2){
                                    videoPlayerShow = true
                                    newViewFilePath = directory + files[index]
                                    newViewFileName = files[index]
                                } else if (yandereDevFileType(file: (directory + files[index])) == 3) {
                                    imageShow = true
                                    newViewFilePath = directory + files[index]
                                } else if (yandereDevFileType(file: (directory + files[index])) == 4) {
                                    textShow = true
                                    newViewFilePath = directory + files[index]
                                } else if (yandereDevFileType(file: (directory + files[index])) == 5){
                                    plistShow = true
                                    newViewFilePath = directory + files[index]
                                    newViewFileName = files[index]
                                } else if (yandereDevFileType(file: (directory + files[index])) == 6){
                                    zipFileShow = true
                                    newViewFileName = files[index]
                                    uncompressZip = true
                                } else if (yandereDevFileType(file: (directory + files[index])) == 7){
                                    spawnShow = true
                                    newViewFilePath = directory + files[index]
                                } else {
                                    selectedFile = FileInfo(name: files[index], id: UUID())
                                }
                            }
                        }) {
                            HStack {
                                if (multiSelect) {
                                    Image(systemName: fileWasSelected[index] ? "checkmark.circle" : "circle")
                                }
                                if (yandereDevFileType(file: (directory + files[index])) == 0) {
                                    if (isDirectoryEmpty(atPath: directory + files[index]) == 1){
                                        Image(systemName: "folder")
                                    } else if (isDirectoryEmpty(atPath: directory + files[index]) == 0){
                                        Image(systemName: "folder.fill")
                                    } else {
                                        Image(systemName: "folder.badge.questionmark")
                                    }
                                    Text(substring(str: files[index], startIndex: files[index].index(files[index].startIndex, offsetBy: 0), endIndex: files[index].index(files[index].endIndex, offsetBy: -1)))
                                } else if (yandereDevFileType(file: (directory + files[index])) == 1) {
                                    Image(systemName: "waveform.circle")
                                    Text(files[index])
                                } else if (yandereDevFileType(file: (directory + files[index])) == 2){
                                    Image(systemName: "video")
                                    Text(files[index])
                                } else if (yandereDevFileType(file: (directory + files[index])) == 3) {
                                    Image(systemName: "photo")
                                    Text(files[index])
                                } else if (yandereDevFileType(file: (directory + files[index])) == 4) {
                                    Image(systemName: "doc.text")
                                    Text(files[index])
                                } else if (yandereDevFileType(file: (directory + files[index])) == 5) {
                                    Image(systemName: "list.bullet")
                                    Text(files[index])
                                } else if (yandereDevFileType(file: (directory + files[index])) == 6){
                                    Image(systemName: "doc.zipper")
                                    Text(files[index])
                                } else if (yandereDevFileType(file: (directory + files[index])) == 7){
                                    Image(systemName: "terminal")
                                    Text(files[index])
                                } else {
                                    Image(systemName: "doc")
                                    Text(files[index])
                                }
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                fileInfoShow = true
                                fileInfo = getFileInfo(forFileAtPath: directory + files[index])
                            }) {
                                Text("Info")
                            }
                            
                            Button(action: {
                                newViewFilePath = directory
                                renameFileCurrentName = files[index]
                                renameFileNewName = files[index]
                                renameFileShow = true
                            }) {
                                Text("Rename")
                            }
                            
                            //if(directory == "/var/mobile/Media/.Trash/"){
                                Button(action: {
                                    deleteFile(atPath: directory + files[index])
                                    updateFiles()
                                }) {
                                    Text("Delete")
                                }
                                .foregroundColor(.red)
                            /*} else if(directory == "/var/mobile/Media/" && files[index] == ".Trash/"){
                                Button(action: {
                                    do {
                                        try FileManager.default.removeItem(atPath: "/var/mobile/Media/.Trash/")
                                    } catch {
                                        print("Error emptying Trash: \(error)")
                                    }
                                    FileManager.default.createDirectory(atPath: "/var/mobile/Media/.Trash/")
                                }) {
                                    Text("Empty Trash")
                                }
                            } else {
                                Button(action: {
                                    moveFile(path: directory + files[index], newPath: ("/var/mobile/Media/.Trash/" + files[index]))
                                    updateFiles()
                                }) {
                                    Text("Move to Trash")
                                }
                            }*/
                            if(deleteOverride){
                                Button(action: {
                                    deleteFile(atPath: directory + files[index])
                                    updateFiles()
                                }) {
                                    Text("Delete")
                                }
                                .foregroundColor(.red)
                            }
                            
                            Button(action: {
                                addToFavoritesShow = true
                                newViewFilePath = directory + files[index]
                                if files[index].hasSuffix("/") {
                                addToFavoritesDisplayName = String(substring(str: files[index], startIndex: files[index].index(files[index].startIndex, offsetBy: 0), endIndex: files[index].index(files[index].endIndex, offsetBy: -1)))
                                } else {
                                    addToFavoritesDisplayName = files[index]
                                }
                                UserDefaults.favorites.synchronize()
                            }) {
                                Text("Add to Favorites")
                            }
                            
                            Button(action: {
                                newViewFilePath = directory
                                newViewArrayNames = [files[index]]
                                moveFileShow = true
                            }) {
                                Text("Move To")
                            }
                            
                            Button(action: {
                                newViewFilePath = directory
                                newViewArrayNames = [files[index]]
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
                    if (directory == "//"){
                        directory = "/"
                    }
                    updateFiles()
                }
                .onPlayPauseCommand {
                    callback = false
                    audioPlayerShow = true
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
                .sheet(isPresented: $textShow, content: {
                    TextView(filePath: $newViewFilePath, isPresented: $textShow)
                })
                .sheet(isPresented: $searchShow, content: { //search files
                    SearchView(directoryToSearch: $directory, isPresenting: $searchShow)
                })
                .sheet(isPresented: $createDirectoryShow, content: { //create dir
                    CreateDirectoryView(directoryPath: directory, isPresented: $createDirectoryShow)
                })
                .sheet(isPresented: $createFileShow, content: { //create file
                    CreateFileView(filePath: directory, isPresented: $createFileShow)
                })
                .sheet(isPresented: $favoritesShow, content: {
                    FavoritesView(directory: $directory, showView: $favoritesShow)
                })
                .sheet(isPresented: $addToFavoritesShow, content: {
                    AddToFavoritesView(filePath: $newViewFilePath, displayName: $addToFavoritesDisplayName, showView: $addToFavoritesShow)
                })
                .sheet(isPresented: $settingsShow, content: {
                    SettingsView()
                })
                .sheet(isPresented: $renameFileShow, content: {
                    RenameFileView(fileName: $renameFileCurrentName, newFileName: $renameFileNewName, filePath: $newViewFilePath, isPresented: $renameFileShow)
                })
                .sheet(isPresented: $moveFileShow, content: {
                    MoveFileView(fileNames: $newViewArrayNames, filePath: $newViewFilePath, multiSelect: $multiSelect, isPresented: $moveFileShow)
                })
                .sheet(isPresented: $copyFileShow, content: {
                    CopyFileView(fileNames: $newViewArrayNames, filePath: $newViewFilePath, multiSelect: $multiSelect, isPresented: $copyFileShow)
                })
                .sheet(isPresented: $videoPlayerShow, content: {
                    VideoPlayerView(videoPath: $newViewFilePath, videoName: $newViewFileName, player: globalAVPlayer)
                })
                .sheet(isPresented: $audioPlayerShow, content: {
                    if(callback){
                        AudioPlayerView(callback: callback, audioPath: $newViewFilePath, audioName: $newViewFileName, player: globalAVPlayer)
                    } else {
                        AudioPlayerView(callback: callback, audioPath: $blankString[0], audioName: $blankString[0], player: globalAVPlayer)
                    }
                })
                .sheet(isPresented: $imageShow, content: {
                    ImageView(imagePath: $newViewFilePath)
                })
                .sheet(isPresented: $plistShow, content: {
                    PlistView(filePath: $newViewFilePath, fileName: $newViewFileName)
                })
                .sheet(isPresented: $zipFileShow, content: {
                    if(uncompressZip){
                        ZipFileView(unzip: uncompressZip, isPresented: $zipFileShow, fileNames: blankString, filePath: $directory, zipFileName: $newViewFileName)
                    } else {
                        ZipFileView(unzip: uncompressZip, isPresented: $zipFileShow, fileNames: multiSelectFiles, filePath: $directory, zipFileName: $blankString[0])
                    }
                })
                .sheet(isPresented: $spawnShow, content: {
                    SpawnView(binaryPath: $newViewFilePath)
                })
                .accentColor(.accentColor)
            }
            
            //sidebar HERE
            /*if(sidebarShow){
                VStack(alignment: .leading) {
                    //i'll reuse this for something idk
                    Text("Devices")
                        .font(.system(size: 40))
                        .bold()
                    HStack {
                        Button(action: {
                            print("s0n")
                        }) {
                            HStack {
                                Image(systemName: "externaldrive")
                                Text("/")
                            }
                        }
                        Spacer()
                    }
                    
                    Text("Places")
                        .font(.system(size: 40))
                        .bold()
                    HStack {
                        Button(action: {
                            directory = "/Applications/"
                            updateFiles()
                        }) {
                            HStack {
                                Image(systemName: "app.badge")
                                Text("Applications")
                            }
                        }
                        Spacer()
                    }
                    HStack {
                        Button(action: {
                            directory = "/var/containers/"
                            updateFiles()
                        }) {
                            HStack {
                                Image(systemName: "app.badge")
                                Text("User Applications")
                            }
                        }
                        Spacer ()
                    }
                    HStack {
                        Button(action: {
                            directory = "/var/mobile/Documents/"
                            updateFiles()
                        }) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Documents")
                            }
                        }
                        Spacer ()
                    }
                }
                .padding(.leading)
            }*/
        }
        .onExitCommand {
            if(directory == "/"){
                exit(69420)
            } else {
                goBack()
            }
        }
    }
    
    var topBar: some View {
        HStack {
            Button(action: {
                if(multiSelect) {
                    multiSelectFiles = files
                    allWereSelected.toggle()
                    if(allWereSelected) {
                        iterateOverFileWasSelected(boolToIterate: true)
                    } else {
                        iterateOverFileWasSelected(boolToIterate: false)
                    }
                } else {
                    resizeMultiSelectArrays()
                    resetMultiSelectArrays()
                    multiSelect = true
                }
            }) {
                if (multiSelect){
                    if (allWereSelected) {
                        Image(systemName: "checkmark.circle")
                        .frame(width:50, height:50)
                    } else {
                        Image(systemName: "circle")
                        .frame(width:50, height:50)
                    }
                } else {
                    Image(systemName: "checkmark.circle")
                        .frame(width:50, height:50)
                }
            }
            
            if (!multiSelect) {
                Button(action: {
                    searchShow = true
                    newViewFilePath = directory
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
            } else {
                Button(action: {
                    moveFileShow = true
                    newViewFilePath = directory
                    newViewArrayNames = multiSelectFiles
                    resizeMultiSelectArrays()
                    resetMultiSelectArrays()
                }) {
                    ZStack {
                        Image(systemName: "doc.on.doc")
                            .frame(width:50, height:50)
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width:15, height:13)
                            .offset(x:-4, y:11.75)
                    }
                }
        
                Button(action: {
                    copyFileShow = true
                    newViewFilePath = directory
                    newViewArrayNames = multiSelectFiles
                    resizeMultiSelectArrays()
                    resetMultiSelectArrays()
                }) {
                    ZStack {
                        Image(systemName: "doc.on.clipboard")
                            .frame(width:50, height:50)
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width:15, height:13)
                            .offset(x:-3.75, y:11.75)
                    }
                }
            
                Button(action: {
                    zipFileShow = true
                    uncompressZip = false
                    newViewFilePath = directory
                    newViewArrayNames = multiSelectFiles
                    resizeMultiSelectArrays()
                }) {
                    Image(systemName: "doc.zipper")
                        .frame(width:50, height:50)
                }
            
                Button(action: {
                    if(directory == "/var/mobile/Media/.Trash/"){
                        for file in multiSelectFiles {
                            deleteFile(atPath: directory + file)
                            updateFiles()
                        }
                        resizeMultiSelectArrays()
                    } else {
                        for file in multiSelectFiles {
                            moveFile(path: directory + file, newPath: "/var/mobile/Media/.Trash/" + file)
                            updateFiles()
                        }
                    }
                }) {
                    ZStack {
                        if(directory == "/var/mobile/Media/.Trash/"){
                            Image(systemName: "trash")
                                .frame(width:50, height:50)
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "trash")
                                .frame(width:50, height:50)
                        }
                    }
                }
            
                Button(action: {
                    multiSelect = false
                    allWereSelected = false
                }) {
                    Image(systemName: "xmark")
                        .frame(width:50, height:50)
                }
            }
        }
        .alignmentGuide(HorizontalAlignment.center) {
            $0[HorizontalAlignment.center]
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    var freeSpace: some View { //this is hardcoded for now, returning mount points wasnt working
        let (doubleValue, stringValue) = freeSpace(path: "/")
        return //VStack {
            //Text("/")
            Text("Free space: " + String(format: "%.2f", doubleValue) + " " + stringValue)
        //}
        .alignmentGuide(.trailing) {
            $0[HorizontalAlignment.trailing]
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var topBarOffset: some View {
        return VStack {
                Text("")
                Text("")
            }
            .alignmentGuide(.leading) {
                $0[HorizontalAlignment.leading]
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
            resizeMultiSelectArrays()
            resetMultiSelectArrays()
        } catch {
            print(error)
            if(substring(str: error.localizedDescription, startIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: -33), endIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: 0)) == "don’t have permission to view it."){
                permissionDenied = true
                multiSelect = false
                goBack()
            }
        }
    }
    
    func goBack() {
        guard directory != "/" else {
            return
        }
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
    
    func freeSpace(path: String) -> (Double, String) {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: path)
            let freeSpace = systemAttributes[.systemFreeSize] as? NSNumber
            if let freeSpace = freeSpace {
                if(freeSpace.doubleValue > 1073741824) {
                    return (bytesToGigabytes(bytes: freeSpace.doubleValue), "GB")
                } else if(freeSpace.doubleValue > 1048576) {
                    return (bytesToMegabytes(bytes: freeSpace.doubleValue), "MB")
                } else if(freeSpace.doubleValue > 1024) {
                    return (bytesToKilobytes(bytes: freeSpace.doubleValue), "KB")
                } else {
                    return (freeSpace.doubleValue, "bytes")
                }
            } else {
                return (0, "?")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return (0, "?")
        }
    }
    
    func bytesToKilobytes(bytes: Double) -> Double {
        let megabytes = bytes / 1024
        return megabytes
    }
    func bytesToMegabytes(bytes: Double) -> Double {
        let megabytes = bytes / (1024 * 1024)
        return megabytes
    }
    func bytesToGigabytes(bytes: Double) -> Double {
        let gigabytes = bytes / (1024 * 1024 * 1024)
        return gigabytes
    }
    //hopefully these are self explanatory?
    
    func yandereDevFileType(file: String) -> Int { //I tried using unified file types but they all returned nil so I have to use this awful yandere dev shit
        //im sorry
        
        let audioTypes: [String] = ["aifc", "m4r", "wav", "flac", "m2a", "aac", "mpa", "xhe", "aiff", "amr", "caf", "m4a", "m4r", "m4b", "mp1", "m1a", "aax", "mp2", "w64", "m4r", "aa", "mp3", "au", "eac3", "ac3", "m4p", "loas"]
        let videoTypes: [String] = ["3gp", "3g2", "avi", "mov", "m4v", "mp4"]
        let imageTypes: [String] = ["png", "tiff", "tif", "jpeg", "jpg", "gif", "bmp", "BMPf", "ico", "cur", "xbm"]
        let archiveTypes: [String] = ["zip", "cbz"]
    
        if file.hasSuffix("/") {
            return 0 //directory
        } else if (audioTypes.contains(where: file.hasSuffix)) {
            return 1 //audio file
        } else if (videoTypes.contains(where: file.hasSuffix)) {
            return 2 //video file
        } else if (imageTypes.contains(where: file.hasSuffix)) {
            return 3 //image
        } else if (isText(filePath: file)) {
            return 4 //text file
        } else if (isPlist(filePath: file)) {
            return 5 //plist
        } else if (archiveTypes.contains(where: file.hasSuffix)){
            return 6 //archive
        } else if (FileManager.default.isExecutableFile(atPath: file)) {
            return 7 //executable
        } else {
            return 69 //unknown
        }
    }
    
    func isText(filePath: String) -> Bool {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return false // File does not exist or cannot be read
        }
    
        let isASCII = data.allSatisfy {
            Character(UnicodeScalar($0)).isASCII
        }
        let isUTF8 = String(data: data, encoding: .utf8) != nil
    
        return isASCII || isUTF8
    }
    
    func isPlist(filePath: String) -> Bool {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return false // File does not exist or cannot be read
        }
    
        let headerSize = 8
        let header = data.prefix(headerSize)
        let isXMLPlist = header.starts(with: [60, 63, 120, 109, 108]) // "<?xml"
        let isBinaryPlist = header.starts(with: [98, 112, 108, 105, 115, 116, 48, 48]) // "bplist00"
    
        return isXMLPlist || isBinaryPlist
    }
    
    func resizeMultiSelectArrays() {
        let range = abs(files.count - fileWasSelected.count)
        if(fileWasSelected.count > files.count){
            fileWasSelected.removeLast(range)
            if(fileWasSelected.count == 0){
                fileWasSelected.append(false)
            }
        } else if(fileWasSelected.count < files.count){
            for _ in 0..<range {
                fileWasSelected.append(false)
            }
        }
    }
    func resetMultiSelectArrays(){
        iterateOverFileWasSelected(boolToIterate: false)
        for i in 0..<multiSelectFiles.count {
            multiSelectFiles[i] = ""
        }
    }
    func iterateOverFileWasSelected(boolToIterate: Bool) {
        for i in 0..<fileWasSelected.count {
            fileWasSelected[i] = boolToIterate
        }
    }
}

struct FileInfo: Identifiable {
    let name: String
    let id: UUID
}
