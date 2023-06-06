//
//  ContentView.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
import Foundation
import AVKit
import MobileCoreServices

struct ContentView: View {
    @State var directory: String
    @State private var files: [String] = []
    @State private var fileInfo: [String] = []
    @State var permissionDenied = false
    @State var deleteOverride = false
    @State var isFocused: Bool = false
    @State var E = false
    @State var E2 = false
    
    @State var masterFiles: [SpartanFile] = []
    
    @State var buttonWidth: CGFloat
    @State var buttonHeight: CGFloat
    @State var isRootless: Bool
    
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
    
    @State var filePerms = 420
    
    @State private var showSubView: [Bool] = [Bool](repeating: false, count: 29)
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
    //hexShow = 22
    //dpkgViewShow = 23
    //dpkgDebViewShow = 24
    //webServerShow = 25
    //fileNotFoundView = 26
    //filePermsEdit = 27
    //carView = 28
    
    @State var globalAVPlayer = AVPlayer()
    @State var isGlobalAVPlayerPlaying = false
    @State var callback = true
    
    @State private var uncompressZip = false
    
    @State private var isLoadingView = false
    
    @State var blankString: [String] = [""]
    
    @State private var nonexistentFile = ""
    
    let paddingInt: CGFloat = -7
    let opacityInt: CGFloat = 1.0
    
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        NavigationView {
            VStack {
                HStack { //input directory + refresh
                    TextField(NSLocalizedString("INPUT_DIRECTORY", comment: "According to all known laws of aviation"), text: $directory, onCommit: {
                        directPathTypeCheckNewViewFileVariableSetter()
                        defaultAction(index: 0, isDirectPath: true)
                    })
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .onAppear {
                        if (substring(str: directory, startIndex: directory.index(directory.startIndex, offsetBy: 0), endIndex: directory.index(directory.startIndex, offsetBy: 5)) == "/var/") {
                            directory = "/private/var/" + substring(str: directory, startIndex: directory.index(directory.startIndex, offsetBy: 5), endIndex: directory.index(directory.endIndex, offsetBy: 0))
                        } //i dont have a way to check if every part of a filepath is a symlink, but this should fix most issues
                    }
                    
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
                                        if(isLoadingView && newViewFileName == files[index]) {
                                            ProgressView()
                                        } else {
                                            if (multiSelect) {
                                                Image(systemName: fileWasSelected[index] ? "checkmark.circle" : "circle")
                                                    .transition(.opacity)
                                            }
                                            let fileType = yandereDevFileType(file: (directory + files[index]))
                                            
                                            switch fileType {
                                            case 0:
                                                if ((directory == "/private/var/containers/Bundle/Application/") || (directory == "/private/var/mobile/Containers/Data/Application/")) {
                                                    Text("Listing app names coming soon")
                                                } else {
                                                    if (isDirectoryEmpty(atPath: directory + files[index]) == 1){
                                                        Image(systemName: "folder")
                                                    } else if (isDirectoryEmpty(atPath: directory + files[index]) == 0){
                                                        Image(systemName: "folder.fill")
                                                    } else {
                                                        Image(systemName: "folder.badge.questionmark")
                                                    }
                                                    Text(removeLastChar(string: files[index]))
                                                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                                }
                                            case 1:
                                                Image(systemName: "waveform")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 2:
                                                Image(systemName: "video")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 3:
                                                Image(systemName: "photo")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 4:
                                                Image(systemName: "doc.text")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 5.1:
                                                Image(systemName: "list.bullet")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 5.2:
                                                Image(systemName: "list.number")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 6:
                                                Image(systemName: "doc.zipper")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 7:
                                                Image(systemName: "terminal")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 8:
                                                Image(systemName: "link")
                                                Text(removeLastChar(string: files[index]))
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 9:
                                                Image(systemName: "archivebox")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 10:
                                                Image(systemName: "tray.full")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            default:
                                                Image(systemName: "doc")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            }
                                        }
                                    }
                                }
                                .contextMenu {
                                    Button(action: {
                                        showSubView[3] = true
                                        newViewFileIndex = index
                                        newViewFileName = files[index]
                                    }) {
                                        Text(NSLocalizedString("INFO", comment: "there is no way a bee should be able to fly."))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    Button(action: {
                                        newViewFilePath = directory
                                        renameFileCurrentName = files[index]
                                        renameFileNewName = files[index]
                                        showSubView[7] = true
                                    }) {
                                        Text(NSLocalizedString("RENAME", comment: "Its wings are too small to get its fat little body off the ground."))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    Button(action: {
                                        showSubView[2] = true
                                        newViewFilePath = directory
                                        newViewArrayNames = [files[index]]
                                        newViewFileIndex = index
                                    }) {
                                        Text(NSLocalizedString("OPENIN", comment: "The bee, of course, flies anyway"))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    if(directory == "/var/mobile/Media/.Trash/"){
                                        Button(action: {
                                            deleteFile(atPath: directory + files[index])
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("DELETE", comment: "because bees don't care what humans think is impossible."))
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
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
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
                                        }
                                    } else {
                                        Button(action: {
                                            moveFile(path: directory + files[index], newPath: ("/var/mobile/Media/.Trash/" + files[index]))
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("GOTOTRASH", comment: "Yellow, black. Yellow, black."))
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
                                        }
                                    }
                                    if(deleteOverride){
                                        Button(action: {
                                            deleteFile(atPath: directory + files[index])
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("DELETE", comment: "Ooh, black and yellow!"))
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
                                        }
                                        .foregroundColor(.red)
                                    }
                                    
                                    Button(action: {
                                        showSubView[17] = true
                                        newViewFilePath = directory + files[index]
                                        if files[index].hasSuffix("/") {
                                            newViewFileName = String(removeLastChar(string: files[index]))
                                        } else {
                                            newViewFileName = files[index]
                                        }
                                        UserDefaults.favorites.synchronize()
                                    }) {
                                        Text(NSLocalizedString("FAVORITESADD", comment: "Let's shake it up a little."))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    Button(action: {
                                        newViewFilePath = directory
                                        newViewArrayNames = [files[index]]
                                        showSubView[8] = true
                                    }) {
                                        Text(NSLocalizedString("MOVETO", comment: "Barry! Breakfast is ready!"))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    Button(action: {
                                        newViewFilePath = directory
                                        newViewArrayNames = [files[index]]
                                        showSubView[9] = true
                                    }) {
                                        Text(NSLocalizedString("COPYTO", comment: "Coming!"))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
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
                                        } else {
                                            let fileType = yandereDevFileType(file: (directory + files[index]))
                                            switch fileType {
                                            case 0:
                                                if (isDirectoryEmpty(atPath: directory + files[index]) == 1) {
                                                    Image(systemName: "folder")
                                                } else if (isDirectoryEmpty(atPath: directory + files[index]) == 0) {
                                                    Image(systemName: "folder.fill")
                                                } else {
                                                    Image(systemName: "folder.badge.minus")
                                                }
                                                Text(removeLastChar(string: files[index]))
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 1:
                                                Image(systemName: "waveform.circle")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 2:
                                                Image(systemName: "video")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 3:
                                                Image(systemName: "photo")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 4:
                                                Image(systemName: "doc.text")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 5.1:
                                                Image(systemName: "list.bullet")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 5.2:
                                                Image(systemName: "list.number")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 6:
                                                Image(systemName: "rectangle.compress.vertical")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 7:
                                                Image(systemName: "terminal")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 8:
                                                Image(systemName: "link")
                                                Text(removeLastChar(string: files[index]))
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 9:
                                                Image(systemName: "archivebox")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 10:
                                                Image(systemName: "tray.full")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            default:
                                                Image(systemName: "doc")
                                                Text(files[index])
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            }
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
                    Button(action: {
                        defaultAction(index: newViewFileIndex, isDirectPath: false)
                        showSubView[1] = false
                    }) {
                        Text(NSLocalizedString("OPEN", comment: "You ever think maybe things work a little too well here?"))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
    
                    Button(action: {
                        fileInfo = getFileInfo(forFileAtPath: directory + files[newViewFileIndex])
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[3] = true
                            newViewFileName = files[newViewFileIndex]
                        }
                    }) {
                        Text(NSLocalizedString("INFO", comment: "there is no way a bee should be able to fly."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        newViewFilePath = directory
                        renameFileCurrentName = files[newViewFileIndex]
                        renameFileNewName = files[newViewFileIndex]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[7] = true
                        }
                    }) {
                        Text(NSLocalizedString("RENAME", comment: "Its wings are too small to get its fat little body off the ground."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        newViewFilePath = directory
                        newViewArrayNames = [files[newViewFileIndex]]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[2] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPENIN", comment: "The bee, of course, flies anyway"))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
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
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
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
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
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
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
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
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
                        }
                        .padding(paddingInt)
                        .opacity(opacityInt)
                    }
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        if files[newViewFileIndex].hasSuffix("/") {
                            newViewFileName = String(removeLastChar(string: files[newViewFileIndex]))
                        } else {
                            newViewFileName = files[newViewFileIndex]
                        }
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[17] = true
                        }
                        UserDefaults.favorites.synchronize()
                    }) {
                        Text(NSLocalizedString("FAVORITESADD", comment: "Let's shake it up a little."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
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
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        newViewFilePath = directory
                        newViewArrayNames = [files[newViewFileIndex]]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[9] = true
                        }
                    }) {
                        Text(NSLocalizedString("COPYTO", comment: "Coming!"))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        showSubView[1] = false
                    }) {
                        Text(NSLocalizedString("DISMISS", comment: "Hang on a second."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                }
                .sheet(isPresented: $showSubView[2]) {
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
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    AVFileOpener
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[4] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_TEXT", comment: "- I can't. I'll pick you up."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        newViewFilePath = directory
                        newViewFileName = files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[22] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_HEX", comment: ""))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        newViewFileName = files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[13] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_PLIST", comment: "Looking sharp."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        newViewFilePath = directory
                        newViewFileName = files[newViewFileIndex]
                        showSubView[23] = true
                    }) {
                        Text(NSLocalizedString("OPEN_DPKG", comment: ""))
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    
                    Button(action: {
                        newViewFilePath = directory
                        newViewFileName = files[newViewFileIndex]
                        showSubView[24] = true
                    }) {
                        Text(NSLocalizedString("OPEN_DPKGDEB", comment: ""))
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    
                    
                    Button(action: {
                        newViewFilePath = directory + files[newViewFileIndex]
                        showSubView[2] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[15] = true
                        }
                    }) {
                        Text(NSLocalizedString("OPEN_SPAWN", comment: "Use the stairs. Your father paid good money for those."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    
                    Button(action: {
                        showSubView[2] = false
                    }) {
                        Text(NSLocalizedString("DISMISS", comment: "Sorry. I'm excited."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
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
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 60)
                            }
                            .font(.system(size: 60))
                        ForEach(fileInfo, id: \.self) { infoPiece in
                            Text(infoPiece)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                        }
                        Button(action: {
                            showSubView[3] = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showSubView[27] = true
                            }
                        }) {
                            Text(NSLocalizedString("PERMSEDIT", comment: "I dont know why I added the sheikah function it took two hours"))
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
                        }
                        
                        Button(action: {
                            showSubView[3] = false
                        }) {
                            Text(NSLocalizedString("DISMISS", comment: "Very proud."))
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
                        }
                        .onAppear {
                            fileInfo = getFileInfo(forFileAtPath: directory + newViewFileName)
                        }
                    }
                }
                .sheet(isPresented: $showSubView[27], onDismiss: {
                    showSubView[3] = true
                }, content: {
                    TextField(NSLocalizedString("PERMSEDIT", comment: "This should have been added a long time ago"), value: $filePerms, formatter: NumberFormatter(), onCommit: {
                        changeFilePerms(filePath: directory + files[newViewFileIndex], permValue: filePerms)
                    })
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .onAppear {
                        filePerms = try! FileManager.default.attributesOfItem(atPath: directory + files[newViewFileIndex])[.posixPermissions] as? Int ?? 000
                    }
                })
                .sheet(isPresented: $showSubView[0], content: {
                    let buttonWidth: CGFloat = 500
                    let buttonHeight: CGFloat = 30
                
                    Button(action: {
                        showSubView[0] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[5] = true
                        }
                    }) {
                        Text(NSLocalizedString("CREATE_FILE", comment: "Please clear the gate."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        showSubView[0] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[6] = true
                        }
                    }) {
                        Text(NSLocalizedString("CREATE_DIR", comment: "Royal Nectar Force on approach."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                    }
                    .padding(paddingInt)
                    .opacity(opacityInt)
                    
                    Button(action: {
                        showSubView[0] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showSubView[20] = true
                        }
                    }) {
                        Text(NSLocalizedString("CREATE_SYM", comment: "Wait a second. Check it out."))
                            .frame(width: buttonWidth, height: buttonHeight)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
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
                    SpawnView(binaryPath: $newViewFilePath, binaryName: $newViewFileName)
                })
                .sheet(isPresented: $showSubView[21], onDismiss: {
                    updateFiles()
                    resetShowSubView()
                }, content: {
                    MountPointsView(directory: $directory, isPresented: $showSubView[21])
                })
                .sheet(isPresented: $showSubView[22], content: {
                    HexView(filePath: $newViewFilePath, fileName: $newViewFileName)
                        .onAppear {
                            isLoadingView = false
                        }
                })
                .sheet(isPresented: $showSubView[23], content: {
                    DpkgView(debPath: $newViewFilePath, debName: $newViewFileName, isPresented: $showSubView[23], isRootless: $isRootless)
                })
                .sheet(isPresented: $showSubView[24], content: {
                    DpkgBuilderView(debInputDir: $newViewFilePath, debInputName: $newViewFileName, isPresented: $showSubView[24], isRootless: $isRootless)
                })
                .sheet(isPresented: $showSubView[25], content: {
                    WebServerView()
                })
                .sheet(isPresented: $showSubView[28], content: {
                    CarView(filePath: $newViewFilePath, fileName: $newViewFileName)
                })
                .alert(isPresented: $showSubView[26]) {
                    Alert(
                        title: Text(NSLocalizedString("SHOW_NOTFOUND", comment: "")),
                        message: Text(NSLocalizedString("SHOW_OLDDEST", comment: "") + nonexistentFile),
                        dismissButton: .default(Text(NSLocalizedString("DISMISS", comment: "")))
                    )
                }
                .accentColor(.accentColor)
            }
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
                
                Button(action: {
                    showSubView[25] = true
                }) {
                    Image(systemName: "server.rack")
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
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
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
    
    @ViewBuilder
    var AVFileOpener: some View {
        let buttonWidth = 500 * (UIScreen.main.nativeBounds.height/1080)
        let buttonHeight = 30 * (UIScreen.main.nativeBounds.height/1080)
        
        Button(action: {
            newViewFilePath = directory + files[newViewFileIndex]
            newViewFileName = files[newViewFileIndex]
            showSubView[2] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showSubView[10] = true
                callback = true
            }
        }) {
            Text(NSLocalizedString("OPEN_AUDIO", comment: "- Barry?"))
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        
        Button(action: {
            newViewFilePath = directory
            newViewFileName = files[newViewFileIndex]
            showSubView[2] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showSubView[11] = true
            }
        }) {
            Text(NSLocalizedString("OPEN_VIDEO", comment: "- Adam?"))
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        
        Button(action: {
            newViewFilePath = directory + files[newViewFileIndex]
            showSubView[2] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showSubView[12] = true
            }
        }) {
            Text(NSLocalizedString("OPEN_IMAGE", comment: "- Can you believe this is happening?"))
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(paddingInt)
        .opacity(opacityInt)
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
            } else {
                fileWasSelected[index] = true
                multiSelectFiles.append(files[index])
            }
        } else {
            multiSelect = false
            let fileType = Int(yandereDevFileType(file: (directory + fileToCheck[index])))
            newViewFilePath = directory
            newViewFileName = fileToCheck[index]
            switch fileType {
            case 0:
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
            case 1:
                showSubView[10] = true
                callback = true
            case 2:
                showSubView[11] = true
            case 3:
                showSubView[12] = true
            case 4:
                showSubView[4] = true
            case 5:
                showSubView[13] = true
            case 6:
                showSubView[14] = true
                uncompressZip = true
            case 7:
                showSubView[15] = true
            case 8:
                print(readSymlinkDestination(path: files[index]))
                directory = readSymlinkDestination(path: files[index]) + "/"
                updateFiles()
            case 9:
                showSubView[23] = true
            case 10:
                showSubView[28] = true
            default:
                isLoadingView = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showSubView[22] = true
                }
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
            masterFiles = []
            for i in 0..<contents.count {
                masterFiles.append(SpartanFile(name: contents[i], path: directory, isSelected: false))
            }
            //print(masterFiles)
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

    func yandereDevFileType(file: String) -> Double { //I tried using unified file types but they all returned nil so I have to use this awful yandere dev shit
        //im sorry
        
        let audioTypes: [String] = ["aifc", "m4r", "wav", "flac", "m2a", "aac", "mpa", "xhe", "aiff", "amr", "caf", "m4a", "m4r", "m4b", "mp1", "m1a", "aax", "mp2", "w64", "m4r", "aa", "mp3", "au", "eac3", "ac3", "m4p", "loas"]
        let videoTypes: [String] = ["3gp", "3g2", "avi", "mov", "m4v", "mp4"]
        let imageTypes: [String] = ["png", "tiff", "tif", "jpeg", "jpg", "gif", "bmp", "BMPf", "ico", "cur", "xbm"]
        let archiveTypes: [String] = ["zip", "cbz"]
        
        if (isSymlink(filePath: file)) {
            return 8 //symlink
        } else if file.hasSuffix("/") {
            return 0 //directory
        } else if (audioTypes.contains(where: file.hasSuffix)) {
            return 1 //audio file
        } else if (videoTypes.contains(where: file.hasSuffix)) {
            return 2 //video file
        } else if (imageTypes.contains(where: file.hasSuffix)) {
            return 3 //image
        } else if (isPlist(filePath: file) != 0) {
            return isPlist(filePath: file)
            //5.1 = xml plist
            //5.2 = bplist
        } else if(isCar(filePath: file)) {
            return 10 //asset catalog
        } else if (isText(filePath: file)) { //these must be flipped because otherwise xml plist detects as text
            return 4 //text file
        } else if (archiveTypes.contains(where: file.hasSuffix)){
            return 6 //archive
        } else if (FileManager.default.isExecutableFile(atPath: file)) {
            return 7 //executable
        } else if (file.hasSuffix(".deb")) {
            return 9 //deb
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
    func isPlist(filePath: String) -> Double {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return 0
        }
        
        let header = String(data: data.subdata(in: 0..<5), encoding: .utf8)
        let xmlHeader = "<?xml"
        let bplistHeader = "bplis"
        
        if header == xmlHeader {
            return 5.1
        } else if header == bplistHeader {
            return 5.2
        } else {
            return 0
        }
    }
    func isSymlink(filePath: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            let resourceValues = try fileURL.resourceValues(forKeys: [.isSymbolicLinkKey])
            if let isSymbolicLink = resourceValues.isSymbolicLink {
                return isSymbolicLink
            }
        } catch {
            print("Error: \(error)")
        }
        return false
    }
    func isCar(filePath: String) -> Bool {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return false
        }
        
        let header = String(data: data.subdata(in: 0..<8), encoding: .utf8)
        let carHeader = "BOMStore"
        
        if header == carHeader {
            return true
        }
        return false
    }

    
    func readSymlinkDestination(path: String) -> String {
        let truePath = "/" + removeLastChar(string: path)
        print(path)
        print(truePath)
        var dest = "/"
        do {
            dest += try FileManager.default.destinationOfSymbolicLink(atPath: truePath)
            print(try FileManager.default.destinationOfSymbolicLink(atPath: truePath))
        } catch {
            print(error.localizedDescription)
        }
        if(!FileManager.default.fileExists(atPath: dest)) {
            nonexistentFile = dest
            showSubView[26] = true
        }
        if(dest == "//") {
            dest = "/" + path
        }
        return dest
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
    
    func removeLastChar(string: String) -> String {
        return String(substring(str: string, startIndex: string.index(string.startIndex, offsetBy: 0), endIndex: string.index(string.endIndex, offsetBy: -1)))
    }
    
    func changeFilePerms(filePath: String, permValue: Int) {
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("File does not exist at path: \(filePath)")
            return
        }
        
        do {
            try FileManager.default.setAttributes([FileAttributeKey.posixPermissions: NSNumber(value: permValue)], ofItemAtPath: filePath)
        } catch {
            print("Error changing file permissions: \(error.localizedDescription)")
        }
    }

}

struct SpartanFile {
    var name: String
    var path: String
    var isSelected: Bool
}
