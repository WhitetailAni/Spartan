//
//  ContentView.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @State var directory: String
    @State private var files: [String] = []
    @State private var fileInfo: [String] = []
    @State var permissionDenied = false
    @State var deleteOverride = false
    @State var isFocused: Bool = false
    @State var E = false
    @State var E2 = false
    
    @State var buttonWidth: CGFloat
    @State var buttonHeight: CGFloat
    
    @State var multiSelect = false
    @State var allWereSelected = false
    @State var multiSelectFiles: [String] = []
    @State var fileWasSelected: [Bool] = [false]
    
    @State var newViewFilePath: String = ""
    @State var newViewArrayNames: [String] = [""]
    @State var newViewFileName: String = ""
    @State private var newViewFileIndex = 0
    
    @State var renameFileCurrentName: String = ""
    @State var renameFileNewName: String = ""
    
    @State private var showSubView: [Bool] = [Bool](repeating: false, count: 23)
    //createFileSelectShow = 0
    //contextMenuShow = 1
    //openInMenu = 2
    //fileInfoShow = 3
    //textShow = 4
    //createFileShow = 5
    //createDirectoryShow = 6
    //renameFileShow = 7
    //moveFileShow = 8
    //copyFileShow = 9
    //audioPlayerShow = 10
    //videoPlayerShow = 11
    //imageShow = 12
    //plistShow = 13
    //zipFileShow = 14
    //spawnShow = 15
    //favoritesShow = 16
    //addToFavoritesShow = 17
    //settingsShow = 18
    //searchShow = 19
    //symlinkShow = 20
    //mountPointsShow = 21
    //spareViewShow = 22
    
    @State var globalAVPlayer = AVPlayer()
    @State var isGlobalAVPlayerPlaying = false
    @State var callback = true
    @State private var uncompressZip = false
    
    @State var blankString: [String] = [""]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack { //input directory + refresh
                    TextField(NSLocalizedString("INPUT_DIRECTORY", comment: "According to all known laws of aviation"), text: $directory, onCommit: {
                        directPathTypeCheckNewViewFileVariableSetter()
                        defaultAction(index: 0, isDirectPath: true)
                    })
                    Button(action: {
                        updateFiles()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                HStack {
                    debugMenu
                        .frame(alignment: .leading)
                    topBar
                        .frame(alignment: .center)
                    freeSpace
                        .frame(alignment: .trailing)
                }
                HStack {
                    List { //directory contents view
                        if #available(tvOS 14.0, *) {
                            Button(action: {
                                goBack()
                            }) {
                                HStack {
                                    Image(systemName: "arrowshape.turn.up.left")
                                    Text("..")
                                }
                            }
                            .contextMenu {
                                Button(action: {
                                    E.toggle()
                                }) {
                                    Text("Toggle Debug")
                                }
                                
                                Button("Dismiss", action: { } )
                            }
                        } else {
                            Button(action: {
                                goBack()
                            }) {
                                HStack {
                                    Image(systemName: "arrowshape.turn.up.left")
                                    Text("..")
                                }
                            }
                        }
                        ForEach(files.indices, id: \.self) { index in
                            if #available(tvOS 14.0, *) {
                                Button(action: {
                                    defaultAction(index: index, isDirectPath: false)
                                }) {
                                    HStack {
                                        if (multiSelect) {
                                            Image(systemName: fileWasSelected[index] ? "checkmark.circle" : "circle")
                                                .transition(.opacity)
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
                                            Image(systemName: "waveform")
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
                                        showSubView[3] = true
                                        newViewFileName = files[index]
                                    }) {
                                        Text(NSLocalizedString("INFO", comment: "there is no way a bee should be able to fly."))
                                    }
                                    
                                    Button(action: {
                                        newViewFilePath = directory
                                        renameFileCurrentName = files[index]
                                        renameFileNewName = files[index]
                                        showSubView[7] = true
                                    }) {
                                        Text(NSLocalizedString("RENAME", comment: "Its wings are too small to get its fat little body off the ground."))
                                    }
                                    
                                    Button(action: {
                                        showSubView[2] = true
                                        newViewFilePath = directory
                                        newViewArrayNames = [files[index]]
                                        newViewFileIndex = index
                                    }) {
                                        Text(NSLocalizedString("OPENIN", comment: "The bee, of course, flies anyway"))
                                    }
                                    
                                    if(directory == "/var/mobile/Media/.Trash/"){
                                        Button(action: {
                                            deleteFile(atPath: directory + files[index])
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("DELETE", comment: "because bees don't care what humans think is impossible."))
                                        }
                                        .foregroundColor(.red)
                                    } else if(directory == "/var/mobile/Media/" && files[index] == ".Trash/"){
                                        Button(action: {
                                            do {
                                                try FileManager.default.removeItem(atPath: "/var/mobile/Media/.Trash/")
                                            } catch {
                                                print("Error emptying Trash: \(error)")
                                            }
                                            do {
                                                try FileManager.default.createDirectory(atPath: "/var/mobile/Media/.Trash/", withIntermediateDirectories: true, attributes: nil)
                                            } catch {
                                                print("Error emptying Trash: \(error)")
                                            }
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("TRASHYEET", comment: "Yellow, black. Yellow, black."))
                                        }
                                    } else {
                                        Button(action: {
                                            moveFile(path: directory + files[index], newPath: ("/var/mobile/Media/.Trash/" + files[index]))
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("GOTOTRASH", comment: "Yellow, black. Yellow, black."))
                                        }
                                    }
                                    if(deleteOverride){
                                        Button(action: {
                                            deleteFile(atPath: directory + files[index])
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("DELETE", comment: "Ooh, black and yellow!"))
                                        }
                                        .foregroundColor(.red)
                                    }
                                    
                                    Button(action: {
                                        showSubView[17] = true
                                        newViewFilePath = directory + files[index]
                                        if files[index].hasSuffix("/") {
                                            newViewFileName = String(substring(str: files[index], startIndex: files[index].index(files[index].startIndex, offsetBy: 0), endIndex: files[index].index(files[index].endIndex, offsetBy: -1)))
                                        } else {
                                            newViewFileName = files[index]
                                        }
                                        UserDefaults.favorites.synchronize()
                                    }) {
                                        Text(NSLocalizedString("FAVORITESADD", comment: "Let's shake it up a little."))
                                    }
                                    
                                    Button(action: {
                                        newViewFilePath = directory
                                        newViewArrayNames = [files[index]]
                                        showSubView[8] = true
                                    }) {
                                        Text(NSLocalizedString("MOVETO", comment: "Barry! Breakfast is ready!"))
                                    }
                                    
                                    Button(action: {
                                        newViewFilePath = directory
                                        newViewArrayNames = [files[index]]
                                        showSubView[9] = true
                                    }) {
                                        Text(NSLocalizedString("COPYTO", comment: "Coming!"))
                                    }
                                    
                                    Button(NSLocalizedString("DISMISS", comment: "Hang on a second.")) { }
                                }
                            } else {
                                Button(action: {
                                    showSubView[1] = true
                                    newViewFilePath = directory
                                    newViewFileName = files[index]
                                    newViewFileIndex = index
                                }) {
                                    HStack {
                                        if (multiSelect) {
                                            Image(systemName: fileWasSelected[index] ? "checkmark.circle" : "circle")
                                        }
                                        if(directory == "/private/var/containers/Bundle/Application/" || directory == "/var/containers/Bundle/Application/") {
                                            Text("app!")
                                        } else if (yandereDevFileType(file: (directory + files[index])) == 0) {
                                            if (isDirectoryEmpty(atPath: directory + files[index]) == 1) {
                                                Image(systemName: "folder")
                                            } else if (isDirectoryEmpty(atPath: directory + files[index]) == 0) {
                                                Image(systemName: "folder.fill")
                                            } else {
                                                Image(systemName: "folder.badge.minus")
                                            }
                                            Text(substring(str: files[index], startIndex: files[index].index(files[index].startIndex, offsetBy: 0), endIndex: files[index].index(files[index].endIndex, offsetBy: -1)))
                                        } else if (yandereDevFileType(file: (directory + files[index])) == 1) {
                                            Image(systemName: "waveform.circle")
                                            Text(files[index])
                                        } else if (yandereDevFileType(file: (directory + files[index])) == 2) {
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
                                        } else if (yandereDevFileType(file: (directory + files[index])) == 6) {
                                            Image(systemName: "rectangle.compress.vertical")
                                            Text(files[index])
                                        } else if (yandereDevFileType(file: (directory + files[index])) == 7) {
                                            Image(systemName: "terminal")
                                            Text(files[index])
                                        } else if (yandereDevFileType(file: (directory + files[index])) == 8) {
                                            Image(systemName: "folder")
                                            Image(systemName: "arrowshape.turn.up.left")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .offset(x: -10, y: -10)
                                            Text(files[index])
                                        } else {
                                            Image(systemName: "doc")
                                            Text(files[index])
                                        }
                                    }
                                }
                            }
                        }
                        .alert(isPresented: $permissionDenied) {
                            Alert(
                                title: Text(NSLocalizedString("SHOW_DENIED", comment: "Here's the graduate.")),
                                message: Text(NSLocalizedString("INFO_DENIED", comment: "You're monsters!")),
                                dismissButton: .default(Text(NSLocalizedString("DISMISS", comment: "You're sky freaks! I love it! I love it!")))
                            )
                        }
                    }
                }
                .sheet(isPresented: $showSubView[1]) {
                    let paddingInt: CGFloat = -7
                    let opacityInt: CGFloat = 1.0
                    
                    Button(action: {
                        defaultAction(index: newViewFileIndex, isDirectPath: false)
                        showSubView[1] = false
                    }) {
                        Text(NSLocalizedString("OPEN", comment: "You ever think maybe things work a little too well here?"))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
    
                    Button(action: {
                        fileInfo = getFileInfo(forFileAtPath: directory + files[newViewFileIndex])
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[3] = true
                            newViewFileName = files[newViewFileIndex]
                        }
                    }) {
                        Text(NSLocalizedString("INFO", comment: "there is no way a bee should be able to fly."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        newViewFilePath = directory
                        renameFileCurrentName = files[newViewFileIndex]
                        renameFileNewName = files[newViewFileIndex]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[7] = true
                        }
                    }) {
                        Text(NSLocalizedString("RENAME", comment: "Its wings are too small to get its fat little body off the ground."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        newViewFilePath = directory
                        newViewArrayNames = [files[newViewFileIndex]]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[2] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPENIN", comment: "The bee, of course, flies anyway"))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    if(directory == "/var/mobile/Media/.Trash/"){
                        Button(action: {
                            deleteFile(atPath: directory + files[newViewFileIndex])
                            updateFiles()
                            showSubView[1] = false
                        }) {
                            Text(NSLocalizedString("DELETE", comment: "because bees don't care what humans think is impossible."))
                                .foregroundColor(.red)
                                .frame(width: buttonWidth, height: buttonHeight)
                        }
                        .padding(paddingInt)
                        .opacity(opacityInt)
                    } else if(directory == "/var/mobile/Media/" && files[newViewFileIndex] == ".Trash/"){
                        Button(action: {
                            do {
                                try FileManager.default.removeItem(atPath: "/var/mobile/Media/.Trash/")
                            } catch {
                                print("Error emptying Trash: \(error)")
                            }
                            do {
                                try FileManager.default.createDirectory(atPath: "/var/mobile/Media/.Trash/", withIntermediateDirectories: true, attributes: nil)
                            } catch {
                                print("Error emptying Trash: \(error)")
                            }
                            showSubView[1] = false
                        }) {
                            Text(NSLocalizedString("TRASHYEET", comment: "Yellow, black. Yellow, black."))
                                .frame(width: buttonWidth, height: buttonHeight)
                        }
                        .padding(paddingInt)
                        .opacity(opacityInt)
                    } else {
                        Button(action: {
                            moveFile(path: directory + files[newViewFileIndex], newPath: ("/var/mobile/Media/.Trash/" + files[newViewFileIndex]))
                            updateFiles()
                            showSubView[1] = false
                        }) {
                            Text(NSLocalizedString("GOTOTRASH", comment: "Yellow, black. Yellow, black."))
                                .frame(width: buttonWidth, height: buttonHeight)
                        }
                        .padding(paddingInt)
                        .opacity(opacityInt)
                    }
                    if(deleteOverride){
                        Button(action: {
                            deleteFile(atPath: directory + files[newViewFileIndex])
                            updateFiles()
                            showSubView[1] = false
                        }) {
                            Text(NSLocalizedString("DELETE", comment: "Ooh, black and yellow!"))
                                .foregroundColor(.red)
                                .frame(width: buttonWidth, height: buttonHeight)
                        }
                        .padding(paddingInt)
                        .opacity(opacityInt)
                    }
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        if files[newViewFileIndex].hasSuffix("/") {
                            newViewFileName = String(substring(str: files[newViewFileIndex], startIndex: files[newViewFileIndex].index(files[newViewFileIndex].startIndex, offsetBy: 0), endIndex: files[newViewFileIndex].index(files[newViewFileIndex].endIndex, offsetBy: -1)))
                        } else {
                            newViewFileName = files[newViewFileIndex]
                        }
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[17] = true
                        }
                        UserDefaults.favorites.synchronize()
                    }) {
                        Text(NSLocalizedString("FAVORITESADD", comment: "Let's shake it up a little."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        newViewFilePath = directory
                        newViewArrayNames = [files[newViewFileIndex]]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[8] = true
                        }
                    }) {
                        Text(NSLocalizedString("MOVETO", comment: "Barry! Breakfast is ready!"))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        newViewFilePath = directory
                        newViewArrayNames = [files[newViewFileIndex]]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[9] = true
                        }
                    }) {
                        Text(NSLocalizedString("COPYTO", comment: "Coming!"))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        showSubView[1] = false
                    }) {
                        Text(NSLocalizedString("DISMISS", comment: "Hang on a second."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                }
                .sheet(isPresented: $showSubView[2]) {
                    let paddingInt: CGFloat = -7
                    let opacityInt: CGFloat = 1.0
                    let buttonWidth: CGFloat = 500
                    let buttonHeight: CGFloat = 30
                    
                    Button(action: {
                        directory = directory + files[newViewFileIndex]
                        updateFiles()
                        print(directory)
                        showSubView[2] = false
                    }) {
                        Text(NSLocalizedString("OPEN_DIRECTORY", comment: "Hello?"))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        newViewFileName = files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[10] = true
                            callback = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_AUDIO", comment: "- Barry?"))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        newViewFilePath = directory
                        newViewFileName = files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[11] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_VIDEO", comment: "- Adam?"))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[12] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_IMAGE", comment: "- Can you believe this is happening?"))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[4] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_TEXT", comment: "- I can't. I'll pick you up."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        newViewFileName = files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[13] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_PLIST", comment: "Looking sharp."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[15] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_SPAWN", comment: "Use the stairs. Your father paid good money for those."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        showSubView[2] = false
                    }) {
                        Text(NSLocalizedString("DISMISS", comment: "Sorry. I'm excited."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                }
                .sheet(isPresented: $E2) {
                    EThree(directory: $directory, files: $files, multiSelectFiles: $multiSelectFiles, fileWasSelected: $fileWasSelected, showSubView: $showSubView, yandereDevFileTypeDebugTransfer: yandereDevFileType)
                }
                .navigationBarHidden(true)
                .onAppear {
                    resetShowSubView()
                    updateFiles()
                    if(yandereDevFileType(file: directory) != 0) {
                        directPathTypeCheckNewViewFileVariableSetter()
                        multiSelect = false
                        defaultAction(index: 0, isDirectPath: true)
                        var components = directory.split(separator: "/")
                        components.removeLast()
                        directory = "/" + components.joined(separator: "/") + "/"
                    }
                }
                .onPlayPauseCommand {
                    callback = false
                    showSubView[10] = true
                }
                .sheet(isPresented: $showSubView[3]) { //file info
                    VStack {
                        Text(NSLocalizedString("SHOW_INFO", comment: "A perfect report card, all B's."))
                            .font(.system(size: 60))
                        ForEach(fileInfo, id: \.self) { infoPiece in
                            Text(infoPiece)
                        }
                        Button(action: {
                            showSubView[3] = false
                        }) {
                            Text(NSLocalizedString("DISMISS", comment: "Very proud."))
                        }
                        .onAppear {
                            fileInfo = getFileInfo(forFileAtPath: directory + newViewFileName)
                        }
                    }
                }
                .sheet(isPresented: $showSubView[0], content: {
                    let paddingInt: CGFloat = -7
                    let opacityInt: CGFloat = 1.0
                    let buttonWidth: CGFloat = 500
                    let buttonHeight: CGFloat = 30
                
                    Button(action: {
                        showSubView[0] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[5] = true
                        }
                    }) {
                        Text(NSLocalizedString("CREATE_FILE", comment: "Please clear the gate."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        showSubView[6] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[6] = true
                        }
                    }) {
                        Text(NSLocalizedString("CREATE_DIR", comment: "Royal Nectar Force on approach."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        showSubView[0] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                            showSubView[20] = true
                        }
                    }) {
                        Text(NSLocalizedString("CREATE_SYM", comment: "Wait a second. Check it out."))
                            .frame(width: buttonWidth, height: buttonHeight)
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                })
                .sheet(isPresented: $showSubView[4], content: {
                    TextView(filePath: $newViewFilePath, fileName: $newViewFileName, isPresented: $showSubView[4])
                })
                .sheet(isPresented: $showSubView[19], content: { //search files
                    SearchView(directoryToSearch: $directory, isPresenting: $showSubView[19])
                })
                .sheet(isPresented: $showSubView[6], content: { //create dir
                    CreateDirectoryView(directoryPath: $directory, isPresented: $showSubView[6])
                })
                .sheet(isPresented: $showSubView[5], content: { //create file
                    CreateFileView(filePath: $directory, isPresented: $showSubView[5])
                })
                .sheet(isPresented: $showSubView[20], content: {
                    CreateSymlinkView(symlinkPath: $directory, isPresented: $showSubView[20])
                })
                .sheet(isPresented: $showSubView[16], content: {
                    FavoritesView(directory: $directory, showView: $showSubView[16])
                })
                .sheet(isPresented: $showSubView[17], content: {
                    AddToFavoritesView(filePath: $newViewFilePath, displayName: $newViewFileName, showView: $showSubView[17])
                })
                .sheet(isPresented: $showSubView[18], content: {
                    SettingsView()
                })
                .sheet(isPresented: $showSubView[7], content: {
                    RenameFileView(fileName: $renameFileCurrentName, newFileName: $renameFileNewName, filePath: $newViewFilePath, isPresented: $showSubView[7])
                })
                .sheet(isPresented: $showSubView[8], content: {
                    MoveFileView(fileNames: $newViewArrayNames, filePath: $newViewFilePath, multiSelect: $multiSelect, isPresented: $showSubView[8])
                })
                .sheet(isPresented: $showSubView[9], content: {
                    CopyFileView(fileNames: $newViewArrayNames, filePath: $newViewFilePath, multiSelect: $multiSelect, isPresented: $showSubView[9])
                })
                .sheet(isPresented: $showSubView[11], content: {
                    VideoPlayerView(videoPath: $newViewFilePath, videoName: $newViewFileName, isPresented: $showSubView[11], player: globalAVPlayer)
                })
                .sheet(isPresented: $showSubView[10], content: {
                    if(callback){
                        AudioPlayerView(callback: callback, audioPath: $newViewFilePath, audioName: $newViewFileName, player: globalAVPlayer, isPresented: $showSubView[10])
                    } else {
                        AudioPlayerView(callback: callback, audioPath: $blankString[0], audioName: $blankString[0], player: globalAVPlayer, isPresented: $showSubView[10])
                    }
                })
                .sheet(isPresented: $showSubView[12], content: {
                    ImageView(imagePath: $newViewFilePath, imageName: $newViewFileName)
                })
                .sheet(isPresented: $showSubView[13], content: {
                    PlistView(filePath: $newViewFilePath, fileName: $newViewFileName)
                })
                .sheet(isPresented: $showSubView[14], content: {
                    if(uncompressZip){
                        ZipFileView(unzip: uncompressZip, isPresented: $showSubView[14], fileNames: blankString, filePath: $directory, zipFileName: $newViewFileName)
                    } else {
                        ZipFileView(unzip: uncompressZip, isPresented: $showSubView[14], fileNames: multiSelectFiles, filePath: $directory, zipFileName: $blankString[0])
                    }
                })
                .sheet(isPresented: $showSubView[15], content: {
                    SpawnView(binaryPath: $newViewFilePath)
                })
                .sheet(isPresented: $showSubView[21], onDismiss: {
                    updateFiles()
                    resetShowSubView()
                }, content: {
                    MountPointsView(directory: $directory, isPresented: $showSubView[21])
                })
                .sheet(isPresented: $showSubView[22], content: {
                    SpareView()
                })
                .accentColor(.accentColor)
            }
        }
        .onExitCommand {
            if(directory == "/"){
                exit(69420)
            } else {
                goBack()
            }
            print(showSubView)
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
                    withAnimation {
                        multiSelect = true
                    }
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
                    showSubView[19] = true
                    newViewFilePath = directory
                }) {
                    Image(systemName: "magnifyingglass")
                        .frame(width:50, height:50)
                }
        
                Button(action: { //new file/directory/symlink
                    showSubView[0] = true
                }) {
                    if #available(tvOS 14.0, *){
                        Image(systemName: "doc.badge.plus")
                            .frame(width:50, height:50)
                    } else {
                        Image(systemName: "doc")
                            .frame(width:50, height:50)
                    }
                }
            
                Button(action: { //mount points
                    showSubView[21] = true
                }) {
                    if #available(tvOS 14.0, *) {
                        Image(systemName: "externaldrive")
                            .frame(width:50, height:50)
                    } else {
                        Image(systemName: "tray.2")
                            .frame(width:50, height:50)
                    }
                }
                
                Button(action: { //favorites
                    showSubView[16] = true
                }) {
                    Image(systemName: "star")
                        .frame(width:50, height:50)
                }
            
                Button(action: { //settings
                    showSubView[18] = true
                }) {
                    Image(systemName: "gear")
                        .frame(width:50, height:50)
                }
            } else {
                Button(action: {
                    showSubView[8] = true
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
                    showSubView[9] = true
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
                    showSubView[14] = true
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
                    withAnimation {
                        multiSelect = false
                    }
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
            Text(NSLocalizedString("FREE_SPACE", comment: "E") + String(format: "%.2f", doubleValue) + " " + stringValue)
        //}
        .alignmentGuide(.trailing) {
            $0[HorizontalAlignment.trailing]
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var debugMenu: some View {
        return VStack {
                if (E) {
                    Button(action: {
                        E2 = true
                    }) {
                        Image(systemName: "ant")
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func defaultAction(index: Int, isDirectPath: Bool) {
        var fileToCheck: [String] = files
        if(isDirectPath) {
            fileToCheck = [""]
        }
    
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
            if (yandereDevFileType(file: (directory + fileToCheck[index])) == 0) {
                do {
                    try FileManager.default.contentsOfDirectory(atPath: directory + fileToCheck[index])
                } catch {
                    if(substring(str: error.localizedDescription, startIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: -33), endIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: 0)) == "don’t have permission to view it."){
                        permissionDenied = true
                        print(permissionDenied)
                    }
                }
                if(!permissionDenied){
                    if(isDirectPath) {
                        updateFiles()
                    } else {
                        directory = directory + fileToCheck[index]
                        updateFiles()
                    }
                }
                print(directory)
            } else if (yandereDevFileType(file: (directory + fileToCheck[index])) == 1) {
                showSubView[10] = true
                callback = true
                newViewFilePath = directory
                newViewFileName = fileToCheck[index]
            } else if (yandereDevFileType(file: (directory + fileToCheck[index])) == 2){
                showSubView[11] = true
                newViewFilePath = directory
                newViewFileName = fileToCheck[index]
            } else if (yandereDevFileType(file: (directory + fileToCheck[index])) == 3) {
                showSubView[12] = true
                newViewFilePath = directory
                newViewFileName = fileToCheck[index]
            } else if (yandereDevFileType(file: (directory + fileToCheck[index])) == 4) {
                showSubView[4] = true
                newViewFilePath = directory
                newViewFileName = fileToCheck[index]
            } else if (yandereDevFileType(file: (directory + fileToCheck[index])) == 5){
                showSubView[13] = true
                newViewFilePath = directory
                newViewFileName = fileToCheck[index]
            } else if (yandereDevFileType(file: (directory + fileToCheck[index])) == 6){
                showSubView[14] = true
                uncompressZip = true
                newViewFileName = fileToCheck[index]
            } else if (yandereDevFileType(file: (directory + fileToCheck[index])) == 7){
                showSubView[15] = true
                newViewFilePath = directory + fileToCheck[index]
            } else {
                showSubView[22] = true
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
            resizeMultiSelectArrays()
            resetMultiSelectArrays()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func goBack() {
        guard directory != "/" else {
            return
        }
        var components = directory.split(separator: "/")
        
        components.removeLast()
        directory = "/" + components.joined(separator: "/") + "/"
        if (directory == "//"){
            directory = "/"
        }
        multiSelect = false
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
    
    func getFileInfo(forFileAtPath: String) -> [String] {
        let fileManager = FileManager.default
    
        do {
            let attributes = try fileManager.attributesOfItem(atPath: forFileAtPath)
    
            let creationDate = attributes[.creationDate] as? Date ?? Date.distantPast
            let modificationDate = attributes[.modificationDate] as? Date ?? Date.distantPast
            
            let fileSize = attributes[.size] as? Int ?? 0
            
            @State var fileOwner: String = ((attributes[.ownerAccountName] as? String)!)
            
            let fileOwnerID = attributes[.groupOwnerAccountID] as? Int ?? 0
            let filePerms = String(format: "%03d", attributes[.posixPermissions] as? Int ?? "000")
            

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            var fileInfoString: [String] = []
            fileInfoString.append(NSLocalizedString("INFO_PATH", comment: "Ma! I got a thing going here.") + forFileAtPath)
            fileInfoString.append(NSLocalizedString("INFO_SIZE", comment: "- You got lint on your fuzz.") + ByteCountFormatter().string(fromByteCount: Int64(fileSize)))
            fileInfoString.append(NSLocalizedString("INFO_CREATION", comment: "- Ow! That's me!") + dateFormatter.string(from: creationDate))
            fileInfoString.append(NSLocalizedString("INFO_MODIFICATION", comment: "- Wave to us! We'll be in row 118,000.") + dateFormatter.string(from: modificationDate))
            fileInfoString.append(NSLocalizedString("INFO_OWNER", comment: "- Bye!") + fileOwner)
            fileInfoString.append(NSLocalizedString("INFO_OWNERID", comment: "Barry, I told you, stop flying in the house!") + String(fileOwnerID))
            fileInfoString.append(NSLocalizedString("INFO_PERMISSIONS", comment: "- Hey, Adam.") + filePerms)
            
            print("help: ", fileInfoString)
            return fileInfoString
        } catch {
            return ["Error: \(error.localizedDescription)"]
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
            //print("Error checking directory contents: \(error.localizedDescription)")
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
                return convertBytes(bytes: freeSpace.doubleValue)
            } else {
                return (0, "?")
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return (0, "?")
        }
    }
    func convertBytes(bytes: Double) -> (Double, String) {
        let units = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB", "BB"]
        var remainingBytes = Double(bytes)
        var i = 0
        
        while remainingBytes >= 1024 && i < units.count - 1 {
            remainingBytes /= 1024
            i += 1
        }
        
        return (remainingBytes, units[i])
    }

    func yandereDevFileType(file: String) -> Int { //I tried using unified file types but they all returned nil so I have to use this awful yandere dev shit
        //im sorry
        
        let audioTypes: [String] = ["aifc", "m4r", "wav", "flac", "m2a", "aac", "mpa", "xhe", "aiff", "amr", "caf", "m4a", "m4r", "m4b", "mp1", "m1a", "aax", "mp2", "w64", "m4r", "aa", "mp3", "au", "eac3", "ac3", "m4p", "loas"]
        let videoTypes: [String] = ["3gp", "3g2", "avi", "mov", "m4v", "mp4"]
        let imageTypes: [String] = ["png", "tiff", "tif", "jpeg", "jpg", "gif", "bmp", "BMPf", "ico", "cur", "xbm"]
        let archiveTypes: [String] = ["zip", "cbz"]
        if file.hasSuffix("/") {
            return 0 //directory
            //return 8 //symlinks wont detect for some stupid reason.
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
            return false
        }
    
        let isASCII = data.allSatisfy {
            Character(UnicodeScalar($0)).isASCII
        }
        let isUTF8 = String(data: data, encoding: .utf8) != nil
    
        return isASCII || isUTF8
    }
    func isPlist(filePath: String) -> Bool {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return false
        }
        let isXMLPlist = data.prefix(8).starts(with: [60, 63, 120, 109, 108]) //xml
        let isBinaryPlist = data.prefix(8).starts(with: [98, 112, 108, 105, 115, 116, 48, 48]) //bplist
        //yeah this one checks the header of the file. fancy!
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
    
    func directPathTypeCheckNewViewFileVariableSetter() {
        if(yandereDevFileType(file: directory) != 0){
            newViewFilePath = String(directory.prefix(through: directory.lastIndex(of: "/")!))
            print(directory)
            print(newViewFilePath)
            let inProgressFileName = directory.split(separator: "/")
            newViewFileName = String(inProgressFileName.last ?? "")
            print(newViewFileName)
            print("did you get it?")
        }
    }
    func resetShowSubView() {
        for i in 0..<showSubView.count {
            showSubView[i] = false
        }
    }
}
