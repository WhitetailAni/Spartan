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
import Swifter
import ApplicationsWrapper
import AssetCatalogWrapper

struct ContentView: View {
    @State var directory: String
    @State private var fileInfo: [String] = []
    @State var permissionDenied = false
    @State var deleteOverride = false
    @State var isFocused: Bool = false
    @State var E = false
    @State var E2 = false
    @State var masterFiles: [SpartanFile] = []
    @State var isRootless: Bool
    
    @State var scaleFactor: CGFloat
    @State var buttonCalc = false
    @State var buttonWidth: CGFloat = 500
    @State var buttonHeight: CGFloat = 30
    
    @State var didSearch = false
    
    @State var multiSelect = false
    @State var allWereSelected = false
    @State var multiSelectFiles: [String] = []
    
    @State var newViewFilePath: String = ""
    @State var newViewArrayNames: [String] = [""]
    @State var newViewFileName: String = ""
    @State private var newViewFileIndex = 0
    
    @State var renameFileCurrentName: String = ""
    @State var renameFileNewName: String = ""
    
    @State var filePerms = 420
    
    @State private var showSubView: [Bool] = [Bool](repeating: false, count: 31)
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
    //tvOS13serverShow = 29
    //fontViewShow = 30
    
    @State var globalAVPlayer: AVPlayer = AVPlayer()
    @State var isGlobalAVPlayerPlaying = false
    @State var callback = true
    
    @State private var uncompressZip = false
    @State private var isLoadingView = false
    @State var blankString: [String] = [""]
    @State private var nonexistentFile = ""
    
    @State var globalHttpServer: HttpServer = HttpServer()
    
    let paddingInt: CGFloat = -7
    let opacityInt: CGFloat = 1.0
    
    let fileManager = FileManager.default
    let appsManager = ApplicationsManager(allApps: LSApplicationWorkspace.default().allApplications())
    
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
                        if(!buttonCalc) {
                            buttonWidth *= scaleFactor
                            buttonHeight *= scaleFactor
                            if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) {
                                buttonWidth *= 1.5
                            }
                            buttonCalc = true
                        }

                        if (directory.count >= 5 && substring(str: directory, startIndex: directory.index(directory.startIndex, offsetBy: 0), endIndex: directory.index(directory.startIndex, offsetBy: 5)) == "/var/") {
                            directory = "/private/var/" + substring(str: directory, startIndex: directory.index(directory.startIndex, offsetBy: 5), endIndex: directory.index(directory.endIndex, offsetBy: 0))
                        } //i dont have a way to check if every part of a filepath is a symlink but that doesn't matter. all that matters is that /var/ always becomes /private/var/
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
                                print(directory)
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
                        ForEach(masterFiles.indices, id: \.self) { index in
                            if #available(tvOS 14.0, *) { //While the .if modifier does allow displaying on a conditional, it can't be used with if #available as #available is a compile-time check, not a runtime check. Which is annoying because that means a large chunk of this view is duplicated code
                                Button(action: {
                                    defaultAction(index: index, isDirectPath: false)
                                }) {
                                    HStack {
                                        if(isLoadingView && newViewFileName == masterFiles[index].name) {
                                            ProgressView()
                                        } else {
                                            if (multiSelect) {
                                                Image(systemName: masterFiles[index].isSelected ? "checkmark.circle" : "circle")
                                                    .transition(.opacity)
                                            }
                                            let fileType = yandereDevFileType(file: (masterFiles[index].fullPath))
                                            
                                            switch fileType {
                                            case 0:
                                                if (directory == "/private/var/containers/Bundle/Application/" || directory == "/private/var/mobile/Containers/Data/Application/" || directory == "/private/var/mobile/Containers/Shared/AppGroup/") {
                                                    let plistDict = NSDictionary(contentsOfFile: masterFiles[index].fullPath + ".com.apple.mobile_container_manager.metadata.plist")
                                                    let bundleID = defineBundleID(plistDict!)
                                                    let groupBundleID = plistDict!["MCMMetadataIdentifier"] as! String
                                                    //in every container folder (whether it's the bundle container, data container, or group container) is a file that contains the app's bundle ID. santander macros do support determining an LSApplicationProxy? from bundle/container/data container folder on **iOS** but not tvOS since sandboxing system is different. Reading from bundle ID ensures that the app definitely exists and someone didn't just create a folder in here, so no issues with nil LSApplicationProxy? elements
                                                    //then the rest of this just reads properties from the LSApplicationProxy.
                                                    
                                                    let app = LSApplicationProxy(forIdentifier: bundleID)
                                                    HStack {
                                                        let image: UIImage? = appsManager.icon(forApplication: app)
                                                        if(image != nil) {
                                                            Image(uiImage: image!)
                                                                .resizable()
                                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                .frame(width: 280 * scaleFactor, height: 168 * scaleFactor)
                                                        } else {
                                                            Image("DefaultIcon")
                                                                .resizable()
                                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                                                .frame(width: 280 * scaleFactor, height: 168 * scaleFactor)
                                                        }
                                                        VStack(alignment: .leading) {
                                                            Text(app.localizedName())
                                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                                }
                                                                .foregroundColor(.blue)
                                                            if (directory == "/private/var/mobile/Containers/Shared/AppGroup/") {
                                                                Text(groupBundleID)
                                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                                    }
                                                            } else {
                                                                Text(bundleID)
                                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                                    }
                                                            }
                                                            Text(removeLastChar(masterFiles[index].name)) //Spartan appends a "/" to every directory element to make other actions easier, but it doesn't look too great when displayed. So removeLastChar just removes the last character in a string (in this case, a slash).
                                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40).foregroundColor(.gray)
                                                                }
                                                                .foregroundColor(.gray)
                                                        }
                                                    }
                                                    Text("")
                                                        .onAppear {
                                                            print(masterFiles[index].fullPath + ".com.apple.mobile_container_manager.metadata.plist")
                                                        } //without this, if you go to UserApplications in Favorites the app crashes. why?? i have absolutely no idea but this fixes it
                                                } else {
                                                    if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 1) {
                                                        Image(systemName: "folder")
                                                    } else if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 0) {
                                                        Image(systemName: "folder.fill")
                                                    } else {
                                                        Image(systemName: "folder.badge.questionmark")
                                                    } //It's a small thing but useful. Spartan will check if a directory has contents or not and display a filled or empty folder based on that. If it doesn't know, it will display a question mark (which usually means you don't have permission to access it)
                                                    Text(removeLastChar(masterFiles[index].name))
                                                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                        }
                                                }
                                            case 1:
                                                Image(systemName: "waveform")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 2:
                                                Image(systemName: "video")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 3:
                                                Image(systemName: "photo")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 4:
                                                Image(systemName: "doc.text")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 5.1:
                                                Image(systemName: "list.bullet")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 5.2:
                                                Image(systemName: "list.number")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 6:
                                                Image(systemName: "doc.zipper")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 7:
                                                Image(systemName: "terminal")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 8:
                                                Image(systemName: "link")
                                                Text(removeLastChar(masterFiles[index].name))
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 9:
                                                Image(systemName: "archivebox")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 10:
                                                Image(systemName: "tray.full")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 11:
                                                Image(systemName: "textformat")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            default:
                                                Image(systemName: "doc")
                                                Text(masterFiles[index].name)
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
                                        newViewFileName = masterFiles[index].name
                                    }) {
                                        Text(NSLocalizedString("INFO", comment: "there is no way a bee should be able to fly."))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    Button(action: {
                                        newViewFilePath = directory
                                        renameFileCurrentName = masterFiles[index].name
                                        renameFileNewName = masterFiles[index].name
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
                                        newViewArrayNames = [masterFiles[index].name]
                                        newViewFileIndex = index
                                    }) {
                                        Text(NSLocalizedString("OPENIN", comment: "The bee, of course, flies anyway"))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    if(directory == "/private/var/mobile/Media/.Trash/"){
                                        Button(action: {
                                            deleteFile(atPath: masterFiles[index].fullPath)
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("DELETE", comment: "because bees don't care what humans think is impossible."))
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
                                        }
                                    } else if(directory == "/private/var/mobile/Media/" && masterFiles[index].name == ".Trash/"){
                                        Button(action: {
                                            do {
                                                try fileManager.removeItem(atPath: "/private/var/mobile/Media/.Trash/")
                                                try fileManager.createDirectory(atPath: "/private/var/mobile/Media/.Trash/", withIntermediateDirectories: true, attributes: nil)
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
                                            moveFile(path: masterFiles[index].fullPath, newPath: ("/private/var/mobile/Media/.Trash/" + masterFiles[index].name))
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("GOTOTRASH", comment: "Yellow, black. Yellow, black."))
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
                                        }
                                    }
                                    if(deleteOverride) { //this never activates, but I leave it in just in case I ever change how this works
                                        Button(action: {
                                            deleteFile(atPath: masterFiles[index].fullPath)
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("DELETE", comment: "Ooh, black and yellow!"))
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
                                        }
                                    }
                                    
                                    Button(action: {
                                        showSubView[17] = true
                                        newViewFilePath = masterFiles[index].fullPath
                                        if masterFiles[index].name.hasSuffix("/") {
                                            newViewFileName = masterFiles[index].name
                                        } else {
                                            newViewFileName = masterFiles[index].name
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
                                        newViewArrayNames = [masterFiles[index].name]
                                        showSubView[8] = true
                                    }) {
                                        Text(NSLocalizedString("MOVETO", comment: "Barry! Breakfast is ready!"))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    Button(action: {
                                        newViewFilePath = directory
                                        newViewArrayNames = [masterFiles[index].name]
                                        showSubView[9] = true
                                    }) {
                                        Text(NSLocalizedString("COPYTO", comment: "Coming!"))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    Button(NSLocalizedString("DISMISS", comment: "Hang on a second.")) { }
                                }
                            } else { //this is the tvOS 13 code. Tapping on an object opens up a select menu since there's no context menus in swiftUI on tvOS 13. You can do the default action, which is the Open button. Then the rest of the context menu is shown in a Sheet
                                Button(action: {
                                    showSubView[1] = true
                                    newViewFilePath = directory
                                    newViewFileName = masterFiles[index].name
                                    newViewFileIndex = index
                                }) {
                                    HStack {
                                        if (multiSelect) {
                                            Image(systemName: masterFiles[index].isSelected ? "checkmark.circle" : "circle")
                                        }
                                        if (directory == "/private/var/containers/Bundle/Application/" || directory == "/private/var/mobile/Containers/Data/Application/" || directory == "/private/var/mobile/Containers/Shared/AppGroup/") {
                                            let plistDict = NSDictionary(contentsOfFile: masterFiles[index].fullPath + ".com.apple.mobile_container_manager.metadata.plist")
                                            let bundleID = defineBundleID(plistDict!)
                                            let groupBundleID = plistDict!["MCMMetadataIdentifier"] as! String
                                            //in every container folder (whether it's the bundle container, data container, or group container) is a file that contains the app's bundle ID. santander macros do support determining an LSApplicationProxy? from bundle/container/data container folder on **iOS** but not tvOS since sandboxing system is different. Reading from bundle ID ensures that the app definitely exists and someone didn't just create a folder in here, so no issues with nil LSApplicationProxy? elements
                                            //then the rest of this just reads properties from the LSApplicationProxy.
                                            
                                            let app = LSApplicationProxy(forIdentifier: bundleID)
                                            HStack {
                                                let image: UIImage? = appsManager.icon(forApplication: app)
                                                if(image != nil) {
                                                    Image(uiImage: image!)
                                                        .resizable()
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        .frame(width: 280 * scaleFactor, height: 168 * scaleFactor)
                                                } else {
                                                    Image("DefaultIcon")
                                                        .resizable()
                                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        .frame(width: 280 * scaleFactor, height: 168 * scaleFactor)
                                                }
                                                VStack(alignment: .leading) {
                                                    Text(app.localizedName())
                                                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                        }
                                                        .foregroundColor(.blue)
                                                    if (directory == "/private/var/mobile/Containers/Shared/AppGroup/") {
                                                        Text(groupBundleID)
                                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                            }
                                                    } else {
                                                        Text(bundleID)
                                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                            }
                                                    }
                                                    Text(removeLastChar(masterFiles[index].name)) //Spartan appends a "/" to every directory element to make other actions easier, but it doesn't look too great when displayed. So removeLastChar just removes the last character in a string (in this case, a slash).
                                                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                            view.scaledFont(name: "BotW Sheikah Regular", size: 40).foregroundColor(.gray)
                                                        }
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        } else {
                                            let fileType = yandereDevFileType(file: (masterFiles[index].fullPath))
                                            switch fileType {
                                            case 0:
                                                if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 1) {
                                                    Image(systemName: "folder")
                                                } else if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 0) {
                                                    Image(systemName: "folder.fill")
                                                } else {
                                                    Image(systemName: "folder.badge.minus")
                                                }
                                                Text(removeLastChar(masterFiles[index].name))
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 1:
                                                Image(systemName: "waveform.circle")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 2:
                                                Image(systemName: "video")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 3:
                                                Image(systemName: "photo")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 4:
                                                Image(systemName: "doc.text")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 5.1:
                                                Image(systemName: "list.bullet")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 5.2:
                                                Image(systemName: "list.number")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 6:
                                                Image(systemName: "rectangle.compress.vertical")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 7:
                                                Image(systemName: "terminal")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 8:
                                                Image(systemName: "link")
                                                Text(removeLastChar(masterFiles[index].name))
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 9:
                                                Image(systemName: "archivebox")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 10:
                                                Image(systemName: "tray.full")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            case 11:
                                                Image(systemName: "textformat")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
                                            default:
                                                Image(systemName: "doc")
                                                Text(masterFiles[index].name)
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
                        fileInfo = getFileInfo(forFileAtPath: masterFiles[newViewFileIndex].fullPath)
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSubView[3] = true
                            newViewFileName = masterFiles[newViewFileIndex].name
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
                        renameFileCurrentName = masterFiles[newViewFileIndex].name
                        renameFileNewName = masterFiles[newViewFileIndex].name
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                        newViewArrayNames = [masterFiles[newViewFileIndex].name]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                    
                    if(directory == "/private/var/mobile/Media/.Trash/"){
                        Button(action: {
                            deleteFile(atPath: masterFiles[newViewFileIndex].fullPath)
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
                    } else if(directory == "/private/var/mobile/Media/" && masterFiles[newViewFileIndex].name == ".Trash/"){
                        Button(action: {
                            do {
                                try fileManager.removeItem(atPath: "/private/var/mobile/Media/.Trash/")
                            } catch {
                                print("Error emptying Trash: \(error)")
                            }
                            do {
                                try fileManager.createDirectory(atPath: "/private/var/mobile/Media/.Trash/", withIntermediateDirectories: true, attributes: nil)
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
                            moveFile(path: masterFiles[newViewFileIndex].fullPath, newPath: ("/private/var/mobile/Media/.Trash/" + masterFiles[newViewFileIndex].name))
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
                            deleteFile(atPath: masterFiles[newViewFileIndex].fullPath)
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
                        newViewFilePath = masterFiles[newViewFileIndex].fullPath
                        if masterFiles[newViewFileIndex].name.hasSuffix("/") {
                            newViewFileName = masterFiles[newViewFileIndex].name
                        } else {
                            newViewFileName = masterFiles[newViewFileIndex].name
                        }
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                        newViewArrayNames = [masterFiles[newViewFileIndex].name]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                        newViewArrayNames = [masterFiles[newViewFileIndex].name]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                    HStack {
                        VStack {
                            Button(action: {
                                directory = directory + masterFiles[newViewFileIndex].name
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
                                newViewFilePath = masterFiles[newViewFileIndex].fullPath
                                showSubView[2] = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                                newViewFileName = masterFiles[newViewFileIndex].name
                                showSubView[2] = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                                newViewFilePath = directory
                                newViewFileName = masterFiles[newViewFileIndex].name
                                showSubView[2] = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showSubView[17] = true
                                }
                            }) {
                                Text(NSLocalizedString("FAVORITESADD", comment: ""))
                                    .frame(width: buttonWidth, height: buttonHeight)
                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                    }
                            }
                            .padding(paddingInt)
                            .opacity(opacityInt)
                        }
                    
                    VStack {
                        Button(action: {
                            newViewFilePath = masterFiles[newViewFileIndex].fullPath
                            newViewFileName = masterFiles[newViewFileIndex].name
                            showSubView[2] = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                            newViewFileName = masterFiles[newViewFileIndex].name
                            showSubView[2] = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showSubView[30] = true
                            }
                        }) {
                            Text(NSLocalizedString("OPEN_FONT", comment: ""))
                                .frame(width: buttonWidth, height: buttonHeight)
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
                        }
                        .padding(paddingInt)
                        .opacity(opacityInt)
                        
                        DpkgFileOpener
                        
                        Button(action: {
                            newViewFilePath = directory
                            newViewFileName = masterFiles[newViewFileIndex].name
                            uncompressZip = true
                            showSubView[2] = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showSubView[14] = true
                            }
                        }) {
                            Text(NSLocalizedString("OPEN_CAR", comment: ""))
                                .frame(width: buttonWidth, height: buttonHeight)
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                }
                        }
                        .padding(paddingInt)
                        .opacity(opacityInt)
                        
                        Button(action: {
                            newViewFileName = masterFiles[newViewFileIndex].name
                            newViewFilePath = directory
                            showSubView[2] = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                    }
                    
                }
                .sheet(isPresented: $E2) {
                    EThree(directory: $directory, files: Binding<[String]>(get: { self.masterFiles.map { $0.name } }, set: { newNames in
                        for (index, newName) in newNames.enumerated() {
                            self.masterFiles[index].name = newName
                        }
                    }), multiSelectFiles: $multiSelectFiles, fileWasSelected: Binding<[Bool]>(get: { self.masterFiles.map { $0.isSelected } }, set: { selected in
                        for (index, selected) in selected.enumerated() {
                            self.masterFiles[index].isSelected = selected
                        }
                    }), showSubView: $showSubView, yandereDevFileTypeDebugTransfer: yandereDevFileType)
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
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                        changeFilePerms(filePath: masterFiles[newViewFileIndex].fullPath, permValue: filePerms)
                    })
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .onAppear {
                        filePerms = try! fileManager.attributesOfItem(atPath: masterFiles[newViewFileIndex].fullPath)[.posixPermissions] as? Int ?? 000
                    }
                    
                })
                .sheet(isPresented: $showSubView[0], content: {
                    Button(action: {
                        showSubView[0] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                .sheet(isPresented: $showSubView[19], onDismiss: {
                    if(didSearch) {
                        if(isDirectory(filePath: newViewFilePath)) {
                            directory = newViewFilePath
                        } else {
                            directory = URL(fileURLWithPath: newViewFilePath).deletingLastPathComponent().path + "/"
                            masterFiles.append(SpartanFile(name: URL(fileURLWithPath: newViewFilePath).lastPathComponent, fullPath: newViewFilePath, isSelected: false))
                            defaultAction(index: masterFiles.count-1, isDirectPath: false)
                        }
                        didSearch = false
                    }
                }, content: { //search files
                    SearchView(directory: $directory, isPresenting: $showSubView[19], selectedFile: $newViewFilePath, didSearch: $didSearch)
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
                .sheet(isPresented: $showSubView[16], onDismiss: {
                    updateFiles()
                }, content: {
                    FavoritesView(directory: $directory, showView: $showSubView[16])
                })
                .sheet(isPresented: $showSubView[17], content: {
                    AddToFavoritesView(filePath: $newViewFilePath, displayName: $newViewFileName, showView: $showSubView[17])
                })
                .sheet(isPresented: $showSubView[18], content: {
                    SettingsView(buttonWidth: $buttonWidth)
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
                    SpawnView(filePath: $newViewFilePath, fileName: $newViewFileName)
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
                    WebServerView(inputServer: $globalHttpServer)
                })
                .sheet(isPresented: $showSubView[28], content: {
                    CarView(filePath: $newViewFilePath, fileName: $newViewFileName)
                })
                .sheet(isPresented: $showSubView[30], content: {
                    FontView(filePath: $newViewFilePath, fileName: $newViewFileName)
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
                UIApplicationSuspend.suspendNow()
            } else {
                goBack()
                print(directory)
            }
        }
    }
    
    var topBar: some View {
        HStack {
            Button(action: {
                if(multiSelect) {
                    multiSelectFiles = masterFiles.map { $0.name }
                    allWereSelected.toggle()
                    if(allWereSelected) {
                        iterateOverFileWasSelected(boolToIterate: true)
                    } else {
                        iterateOverFileWasSelected(boolToIterate: false)
                    }
                } else {
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
                
                if #available(tvOS 14.0, *) {
                    Button(action: {
                        showSubView[25] = true
                    }) {
                        Image(systemName: "server.rack")
                            .frame(width:50, height:50)
                    }
                    .contextMenu {
                        serverButton
                    }
                } else {
                    Button(action: {
                        showSubView[29] = true
                    }) {
                        Image(systemName: "server.rack")
                            .frame(width:50, height:50)
                    }
                    .sheet(isPresented: $showSubView[29], content: {
                        serverButton
                    })
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
                }) {
                    Image(systemName: "doc.zipper")
                        .frame(width:50, height:50)
                }
            
                Button(action: {
                    if(directory == "/private/var/mobile/Media/.Trash/"){
                        for file in multiSelectFiles {
                            deleteFile(atPath: directory + file)
                            updateFiles()
                        }
                    } else {
                        for file in multiSelectFiles {
                            moveFile(path: directory + file, newPath: "/private/var/mobile/Media/.Trash/" + file)
                            updateFiles()
                        }
                    }
                }) {
                    ZStack {
                        if(directory == "/private/var/mobile/Media/.Trash/"){
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
    
    @ViewBuilder
    var serverButton: some View {
        if #unavailable(tvOS 16.0) {
            Button(action: {
                showSubView[29] = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSubView[25] = true
                }
            }) {
                Text(NSLocalizedString("SERVERHEAD", comment: ""))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .frame(width: buttonWidth, height: buttonHeight)
            }
            .padding(paddingInt)
            .opacity(opacityInt)
        }
    
        Button(action: { //mount points
            showSubView[21] = true
        }) {
            Text(NSLocalizedString("MOUNTPOINTS", comment: ""))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                .frame(width: buttonWidth, height: buttonHeight)
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        Button(action: {
            WebServerView(inputServer: $globalHttpServer).serverStart(server: globalHttpServer)
        }) {
            Text(NSLocalizedString("SERVERHEADLESS", comment: ""))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
                .frame(width: buttonWidth, height: buttonHeight)
        }
        .padding(paddingInt)
        .opacity(opacityInt)
    }
    
    var freeSpace: some View { //this is hardcoded for now, returning mount points wasnt working
        let (doubleValue, stringValue) = freeSpace(path: "/")
        return //VStack {
            //Text("/")
            Text(NSLocalizedString("FREE_SPACE", comment: "E") + String(format: "%.2f", doubleValue) + " " + stringValue)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 32)
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
        Button(action: {
            newViewFilePath = masterFiles[newViewFileIndex].fullPath
            newViewFileName = masterFiles[newViewFileIndex].name
            showSubView[2] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
            newViewFileName = masterFiles[newViewFileIndex].name
            showSubView[2] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
            newViewFilePath = masterFiles[newViewFileIndex].fullPath
            showSubView[2] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
    
    @ViewBuilder
    var DpkgFileOpener: some View {
        Button(action: {
            newViewFilePath = directory
            newViewFileName = masterFiles[newViewFileIndex].name
            showSubView[2] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showSubView[23] = true
            }
        }) {
            Text(NSLocalizedString("OPEN_DPKG", comment: ""))
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(paddingInt)
        .opacity(opacityInt)
        
        Button(action: {
            newViewFilePath = directory
            newViewFileName = masterFiles[newViewFileIndex].name
            showSubView[2] = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showSubView[24] = true
            }
        }) {
            Text(NSLocalizedString("OPEN_DPKGDEB", comment: ""))
                .frame(width: buttonWidth, height: buttonHeight)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                }
        }
        .padding(paddingInt)
        .opacity(opacityInt)
    }
    
    func defaultAction(index: Int, isDirectPath: Bool) {
        var fileToCheck: [String] = masterFiles.map { $0.name }
        if(isDirectPath) {
            fileToCheck = [""]
        }
    
        if (multiSelect) {
            if(masterFiles[index].isSelected){
                let searchedIndex = multiSelectFiles.firstIndex(of: masterFiles[newViewFileIndex].name)
                multiSelectFiles.remove(at: searchedIndex!)
                masterFiles[index].isSelected = false
            } else {
                masterFiles[index].isSelected = true
                multiSelectFiles.append(masterFiles[newViewFileIndex].name)
            }
        } else {
            multiSelect = false
            let fileType = Int(yandereDevFileType(file: (directory + fileToCheck[index])))
            newViewFilePath = directory
            newViewFileName = fileToCheck[index]
            switch fileType {
            case 0:
                do {
                    try fileManager.contentsOfDirectory(atPath: directory + fileToCheck[index])
                } catch {
                    if(substring(str: error.localizedDescription, startIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: -33), endIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: 0)) == "don’t have permission to view it."){
                        permissionDenied = true
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
                directory = readSymlinkDestination(path: directory + fileToCheck[index]) + "/"
                updateFiles()
            case 9:
                showSubView[23] = true
            case 10:
                showSubView[28] = true
            case 11:
                showSubView[30] = true
            default:
                isLoadingView = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSubView[22] = true
                }
            }
        }
    }

    func updateFiles() {
        if UserDefaults.settings.bool(forKey: "autoComplete") && !directory.hasSuffix("/") && isDirectory(filePath: directory) {
            directory = directory + "/"
        }
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
            var files: [String]
            files = contents.map { file in
                let filePath = "/" + directory + "/" + file
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
                return isDirectory.boolValue ? "\(file)/" : file
            }
            masterFiles = []
            for i in 0..<contents.count {
                masterFiles.append(SpartanFile(name: files[i], fullPath: directory + files[i], isSelected: false))
            }
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
            try fileManager.removeItem(atPath: path)
        } catch {
            print("Failed to delete file: \(error.localizedDescription)")
        }
    }
    
    func getFileInfo(forFileAtPath: String) -> [String] {
        let fileManager = fileManager
    
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
    
    func isDirectoryEmpty(atPath: String) -> Int {
        do {
            let files = try fileManager.contentsOfDirectory(atPath: atPath)
            if(files.isEmpty){
                return 1
            } else {
                return 0
            }
        } catch {
            return 2
        }
    }
    
    func moveFile(path: String, newPath: String) {
        do {
            try fileManager.moveItem(atPath: path, toPath: newPath)
        } catch {
            print("Failed to move file: \(error.localizedDescription)")
        }
    }
    
    func freeSpace(path: String) -> (Double, String) {
        do {
            let systemAttributes = try fileManager.attributesOfFileSystem(forPath: path)
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
        let fontTypes: [String] = ["ttf", "otf", "ttc", "pfb", "pfa"]
        
        if (isSymlink(filePath: file)) {
            return 8 //symlink
        } else if (isDirectory(filePath: file)) {
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
        } else if (fontTypes.contains(where: file.hasSuffix)) {
            return 11
        } else if(isCar(filePath: file)) {
            return 10 //asset catalog
        } else if (isText(filePath: file)) { //these must be flipped because otherwise xml plist detects as text
            return 4 //text file
        } else if (archiveTypes.contains(where: file.hasSuffix)){
            return 6 //archive
        } else if (fileManager.isExecutableFile(atPath: file)) {
            return 7 //executable
        } else if (file.hasSuffix(".deb")) {
            return 9 //deb
        } else {
            return 69 //unknown
        }
    }
    func isDirectory(filePath: String) -> Bool {
        var isDirectory: ObjCBool = false
        FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
        return isDirectory.boolValue
    }
    func isText(filePath: String) -> Bool {
        guard let data = fileManager.contents(atPath: filePath) else {
            return false
        }
    
        let isASCII = data.allSatisfy {
            Character(UnicodeScalar($0)).isASCII
        }
        let isUTF8 = String(data: data, encoding: .utf8) != nil
    
        return isASCII || isUTF8
    }
    func isPlist(filePath: String) -> Double {
        guard let data = fileManager.contents(atPath: filePath) else {
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
        guard let data = fileManager.contents(atPath: filePath) else {
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
        print(try! fileManager.destinationOfSymbolicLink(atPath: path))
        var dest = "/"
        do {
            dest += try fileManager.destinationOfSymbolicLink(atPath: path)
        } catch {
            print(error.localizedDescription)
        }
        if(!fileManager.fileExists(atPath: dest)) {
            nonexistentFile = dest
            showSubView[26] = true
        }
        if(dest == "//") {
            dest = "/" + path
        }
        return dest
    }
    func resetMultiSelectArrays(){
        iterateOverFileWasSelected(boolToIterate: false)
        for i in 0..<multiSelectFiles.count {
            multiSelectFiles[i] = ""
        }
    }
    func iterateOverFileWasSelected(boolToIterate: Bool) {
        for i in 0..<masterFiles.count {
            masterFiles[i].isSelected = boolToIterate
        }
    }
    
    func directPathTypeCheckNewViewFileVariableSetter() {
        if(yandereDevFileType(file: directory) != 0){
            newViewFilePath = String(directory.prefix(through: directory.lastIndex(of: "/")!))
            let inProgressFileName = directory.split(separator: "/")
            newViewFileName = String(inProgressFileName.last ?? "")
        }
    }
    func resetShowSubView() {
        for i in 0..<showSubView.count {
            showSubView[i] = false
        }
    }
    
    func changeFilePerms(filePath: String, permValue: Int) {
        guard fileManager.fileExists(atPath: filePath) else {
            print("File does not exist at path: \(filePath)")
            return
        }
        
        do {
            try fileManager.setAttributes([FileAttributeKey.posixPermissions: NSNumber(value: permValue)], ofItemAtPath: filePath)
        } catch {
            print("Error changing file permissions: \(error.localizedDescription)")
        }
    }

    func removeLastChar(_ string: String) -> String {
        return String(substring(str: string, startIndex: string.index(string.startIndex, offsetBy: 0), endIndex: string.index(string.endIndex, offsetBy: -1)))
    }
    
    func defineBundleID(_ plistDict: NSDictionary) -> String {
        if (directory == "/private/var/mobile/Containers/Shared/AppGroup/") {
            return trimGroupBundleID(plistDict["MCMMetadataIdentifier"] as! String)!
        } else {
            return plistDict["MCMMetadataIdentifier"] as! String
        }
    }
    
    func trimGroupBundleID(_ string: String) -> String? {
        let components = string.components(separatedBy: ".")
        guard components.count >= 3 else {
            return nil
        }
        return components.suffix(3).joined(separator: ".")
    }
}

struct SpartanFile {
    var name: String
    var fullPath: String
    var isSelected: Bool
}
