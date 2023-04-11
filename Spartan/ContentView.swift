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

struct ContentView: View {
    @Binding var directory: String
    @State private var files: [String] = []
    @State private var selectedFile: FileInfo?
    @State private var textSuccess = false
    @State private var fileInfo: String = ""
    @State var permissionDenied = false
    @State var fileInfoShow = false
    
    @State private var directoryListShow = false
    @State var directoryListPath: String = ""
    
    @State private var renameFileShow = false
    @State var renameFileCurrentPath: String = ""
    @State var renameFileCurrentName: String = ""
    @State var renameFileNewName: String = ""
    
    @State private var sidebarShow = false
    private let sidebarFocus = UIFocusGuide()
    
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
    
    @State private var imageShow = false
    @State var imagePath: String = ""
    
    @State private var plistShow = false
    @State var plistPath: String = ""
    
    @State private var addToFavoritesShow = false
    @State private var addToFavoritesFilePath: String = ""
    @State private var addToFavoritesDisplayName: String = ""
    
    var body: some View {
        ZStack {
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
                        directoryListShow = true
                        directoryListPath = goBack()
                    }) {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.backward")
                            Text("..")
                        }
                    }
                    ForEach(files, id: \.self) { file in
                        Button(action: {
                            print(yandereDevFileType(file: (directory + file)))
                            if file.hasSuffix("/") {
                                directoryListShow = true
                                directoryListPath = directory + file
                                print(directory)
                            } else if (file.hasSuffix("aifc") || file.hasSuffix("m4r") || file.hasSuffix("wav") || file.hasSuffix("flac") || file.hasSuffix("m2a") || file.hasSuffix("aac") || file.hasSuffix("mpa") || file.hasSuffix("xhe") || file.hasSuffix("aiff") || file.hasSuffix("amr") || file.hasSuffix("caf") || file.hasSuffix("m4a") || file.hasSuffix("m4r") || file.hasSuffix("m4b") || file.hasSuffix("mp1") || file.hasSuffix("m1a") || file.hasSuffix("aax") || file.hasSuffix("mp2") || file.hasSuffix("w64") || file.hasSuffix("m4r") || file.hasSuffix("aa") || file.hasSuffix("mp3") || file.hasSuffix("au") || file.hasSuffix("eac3") || file.hasSuffix("ac3") || file.hasSuffix("m4p") || file.hasSuffix("loas")) {
                                audioPlayerShow = true
                                audioPlayerPath = directory + file
                            } else if (file.hasSuffix("3gp") || file.hasSuffix("3g2") || file.hasSuffix("avi") || file.hasSuffix("mov") || file.hasSuffix("m4v") || file.hasSuffix("mp4")){
                                videoPlayerShow = true
                                videoPlayerPath = directory + file
                            } else if (file.hasSuffix("png")) {
                                imageShow = true
                                imagePath = directory + file
                            } else if (file.hasSuffix("plist")) {
                                plistShow = true
                                plistPath = directory + file
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
                                } else if (file.hasSuffix("png")) {
                                    Image(systemName: "photo")
                                    Text(file)
                                } else if (file.hasSuffix("plist")) {
                                    Image(systemName: "list.bullet")
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
                                renameFileNewName = file
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
                                addToFavoritesShow = true
                                addToFavoritesFilePath = directory + file
                                if file.hasSuffix("/") {
                                addToFavoritesDisplayName = String(substring(str: file, startIndex: file.index(file.startIndex, offsetBy: 0), endIndex: file.index(file.endIndex, offsetBy: -1)))
                                } else {
                                    addToFavoritesDisplayName = file
                                }
                                UserDefaults.favorites.synchronize()
                            }) {
                                Text("Add to Favorites")
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
                .sheet(isPresented: $directoryListShow, content: {
                    ContentView(directory: $directoryListPath)
                })
                .sheet(isPresented: $searchShow, content: { //search files
                    SearchView(directoryToSearch: $directory)
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
                    AddToFavoritesView(filePath: $addToFavoritesFilePath, displayName: $addToFavoritesDisplayName, showView: $addToFavoritesShow)
                })
                .sheet(isPresented: $settingsShow, content: {
                    SettingsView()
                })
                .sheet(isPresented: $renameFileShow, content: {
                    RenameFileView(fileName: $renameFileCurrentName, newFileName: $renameFileNewName, filePath: $renameFileCurrentPath, isPresented: $renameFileShow)
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
                .sheet(isPresented: $imageShow, content: {
                    ImageView(imagePath: $imagePath)
                })
                .sheet(isPresented: $plistShow, content: {
                    PlistView(filePath: $plistPath)
                })
                .accentColor(.accentColor)
            }
            
            //sidebar HERE
            if(sidebarShow){
                VStack(alignment: .leading) {
                    
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
            }
        }
    }
    
    var topBar: some View {
        HStack {
            Button(action: {
                sidebarShow.toggle()
            }) {
                Image(systemName: "list.bullet")
                    .frame(width:50, height:50)
            }
            
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
        } catch {
            print(error)
            if(substring(str: error.localizedDescription, startIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: -33), endIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: 0)) == "don’t have permission to view it."){
                permissionDenied = true
                directory = goBack()
                updateFiles()
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
    
    func goBack() -> String {
        guard directory != "/" else {
            return "/"
        }
        var components = directory.split(separator: "/")
    
        components.removeLast()
        return "/" + components.joined(separator: "/") + "/"
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
}

struct FileInfo: Identifiable {
    let name: String
    let id: UUID
}
