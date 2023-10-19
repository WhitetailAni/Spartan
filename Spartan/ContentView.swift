//
//  ContentView.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//
//  This is the biggest file in Spartan. It's also the worst since it has the most stuff going on, and not all of it was coded well. Perks of learning as you go.
//  Some of it is unused leftovers, I just don't know what all isn't used so it's left as-is.
//

import SwiftUI
import Foundation
import AVKit
import AVFoundation
import MobileCoreServices
import ApplicationsWrapper
import AssetCatalogWrapper
import DiskImages2Bridge
import SVGWrapper
//import GCDWebServer

struct ContentView: View {
    @State var test = false
    @State var testTwo = false
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
    
    @State var lol: [String: Any] = [:]
    
    @State private var showSubView: [Bool] = [Bool](repeating: false, count: 33)
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
    //tvOS13serverShow = 29  # some things are like this due to tvOS 13 (no context menu) limitations. I would drop 13 if I could but I'm not abandoning 13.4.8 people.
    //fontViewShow = 30
    //choosing between opening an image as an SVG or not an SVG = 31
    //dmgMountViewShow = 32
    
    @Binding var globalAVPlayer: AVPlayer //this is because Spartan has the ability to play music without the AudioPlayerView being shown. It took about a week to get working properly and I'm proud of it
    @State var isGlobalAVPlayerPlaying = false
    @State var callback = true
    
    //@Binding var webServer: GCDWebUploader
    
    @State private var uncompressZip = false
    @State private var isLoadingView = false
    @State var blankString: [String] = [""] //dont question it
    @State private var nonexistentFile = "" //REALLY dont question it
    
    @State private var isImageSVG = false
    
    var body: some View {
        VStack {
            VStack {
                HStack { //input directory + refresh
                    TextField(NSLocalizedString("INPUT_DIRECTORY", comment: "According to all known laws of aviation"), text: $directory, onCommit: {
                        if directory == "" {
                            directory = "/"
                        }
                        directPathTypeCheckNewViewFileVariableSetter()
                        defaultAction(index: 0, isDirectPath: true)
                        
                        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9_\\-\\./]+$")
                        if regex.firstMatch(in: directory, options: [], range: NSRange(location: 0, length: directory.utf16.count)) == nil {
                            directory = "/"
                        }
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

                        directory = varFixup(directory) //varFixup changes all /var paths to /private/var. this fixes an issue with symlinks that I couldn't find a better way to do. FileManager can't see symlinks properly (at least on 15.0) - they're simultaenously nonexistent files and transparent files, so I just have to work around them. Clicking on a symlink uses an old objc api to ask for its destination, and then sets the symlink to that - that way you can't get stuck in a symlink loop (which I did, and I can't get rid of the loop on my filesystem)
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
                                    Text("..") //Originally this was the only way to go back a directory. Using the menu button works now, but it's slower than just spamming this. So I leave it.
                                }
                            }
                            .contextMenu {
                                Button(action: {
                                    E.toggle()
                                }) {
                                    Text("Toggle Debug")
                                }
                                
                                Button("Dismiss", action: { } ) //the only way to exit a tvOS context menu is to press a button. nothing else
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
                                        if(masterFiles[index].isLoadingFile) {
                                            ProgressView()
                                        } else {
                                            if (multiSelect) {
                                                Image(systemName: masterFiles[index].isSelected ? "checkmark.circle" : "circle")
                                                    .transition(.opacity)
                                            }
                                            switch masterFiles[index].fileType {
                                            case 0:
                                                if (directory == "/Applications/") { //shush.
                                                    let app = appsManager.application(forBundleURL: URL(fileURLWithPath: masterFiles[index].fullPath))
                                                    if app != nil {
                                                        let plistDict = NSDictionary(contentsOfFile: masterFiles[index].fullPath + "Info.plist")
                                                        let bundleID = plistDict?["CFBundleIdentifier"] as? String ?? "com.apple.TVAppStore" //I know this app will always exist, so I use it as a failover.
                                                        HStack {
                                                            let image: UIImage? = appsManager.icon(forApplication: app!)
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
                                                                Text(app!.localizedName())
                                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                                    }
                                                                    .foregroundColor(.blue)
                                                                Text(bundleID)
                                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                                    }
                                                                Text(removeLastChar(masterFiles[index].name)) //Spartan appends a "/" to every directory element to make other actions easier, but it doesn't look too great when displayed. So removeLastChar just removes the last character in a string (in this case, a slash). no, this wasn't always a function - until beta 2 it was just manual substring stuff on every Text()
                                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40).foregroundColor(.gray)
                                                                    }
                                                                    .foregroundColor(.gray)
                                                            }
                                                        }
                                                    } else {
                                                        if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 1) {
                                                            Image(systemName: "folder")
                                                        } else if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 0) {
                                                            Image(systemName: "folder.fill")
                                                        } else {
                                                            Image(systemName: "folder.badge.questionmark")
                                                        } //this is a surprisingly useful feature that is one of the first things I implemented. It's subtle but incredibly handy if you realize it - just like the numbers by repos in Sileo that tells you how many packages you have installed. it's funny how many people don't know that that's what it does (i didn't for awhile)
                                                        Text(removeLastChar(masterFiles[index].name))
                                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                            } //you'll be seeing this a lot. i might switch it to a separate view modifier that takes a font size as an Int but im lazy and can do that later
                                                    }
                                                } else if (directory == "/private/var/containers/Bundle/Application/" || directory == "/private/var/mobile/Containers/Data/Application/" || directory == "/private/var/mobile/Containers/Shared/AppGroup/") {
                                                    let plistPath: String = masterFiles[index].fullPath + ".com.apple.mobile_container_manager.metadata.plist"
                                                    if fileManager.fileExists(atPath: plistPath) {
                                                        let plistDict = NSDictionary(contentsOfFile: plistPath)
                                                        let bundleID = defineBundleID(plistDict ?? NSDictionary(dictionaryLiteral: ("MCMMetadataIdentifier", "lol.whitetailani.Spartan"))) //these optionals are literally never used but otherwise it crashes when you try and open from favorites so L
                                                        let groupBundleID = plistDict?["MCMMetadataIdentifier"] as? String ?? "lol.whitetailani.Spartan"
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
                                                                Text(removeLastChar(masterFiles[index].name))
                                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40).foregroundColor(.gray)
                                                                    }
                                                                    .foregroundColor(.gray)
                                                            }
                                                        }
                                                    } else {
                                                        if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 1) {
                                                            Image(systemName: "folder")
                                                        } else if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 0) {
                                                            Image(systemName: "folder.fill")
                                                        } else {
                                                            Image(systemName: "folder.badge.questionmark")
                                                        } //as you can see, more duplicated code. i love tvos 13
                                                        Text(removeLastChar(masterFiles[index].name))
                                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                            }
                                                    }
                                                } else {
                                                    if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 1) {
                                                        Image(systemName: "folder")
                                                    } else if (isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 0) {
                                                        Image(systemName: "folder.fill")
                                                    } else {
                                                        Image(systemName: "folder.badge.questionmark")
                                                    } //It's a small thing but useful. Spartan will check if a directory has contents or not and display a filled or empty folder based on that. If it doesn't know, it will display a question mark (which usually means you don't have permission to access it)
                                                    
                                                    //future me wants you to know i forgot i wrote comments. im currently doing nothing in my CS class so I'm actually documenting/explaining stuff for once.
                                                    //the person behind me is getting confused by string arrays help
                                                    Text(removeLastChar(masterFiles[index].name))
                                                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                        }
                                                }
											//the rest of this switch case is incredibly simple and basically the same thing, just the Image changes. I would just keep the text the same but I can't due to directories.
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
                                            case 5.9:
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
                                                if(isDirectory(filePath: masterFiles[index].fullPath)) {
                                                    Text(removeLastChar(masterFiles[index].name))
                                                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                        }
                                                } else {
                                                    Text(masterFiles[index].name)
                                                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                        }
                                                }
                                                /*this handling is done in case a symlink points to a file and not a directory.
                                                early with symlink support, I assumed symlinks all pointed to directories and it broke BADLY*/
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
											case 12:
												Image(systemName: "photo.fill")
                                                Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
											case 13:
												Image(systemName: "externaldrive")
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
                                        newViewFileIndex = index
                                        newViewFileName = masterFiles[index].name
                                        showSubView[3] = true
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
                                        showSubView[7] = true //In early development I just created new variables for stuff like this. i then switched to a unified newViewFilePath + newViewFileName set, but this is a bit before that and I legitimately do not know how I set up renaming files. i don't want to touch it, since it works.
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
                                    } else if (directory == "/private/var/mobile/Media/" && masterFiles[index].name == ".Trash/") {
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
                            } else { //this is the tvOS 13 code. Tapping on an object opens up a select menu since there's no context menus on tvOS 13. You can do the default action, which is the Open button. Then the rest of the context menu is shown in a Sheet
                            
                            //future me wants you to know that i don't really test this. i need to buy another HD for 13 testing but i am more interested in putting 18tb in an xserve
                            //if it's broken, please let me know and i'll try to fix it with the 13.4 sim i downloaded once
                            
                            //most of the code is actually just copy and pasted, so older comments are duplicated as well. i just changed how it's handled slightly
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
                                        if (directory == "/Applications/") {
                                            let app = appsManager.application(forBundleURL: URL(fileURLWithPath: masterFiles[index].fullPath))
                                            Text(app!.localizedName())
                                        } else if (directory == "/private/var/containers/Bundle/Application/" || directory == "/private/var/mobile/Containers/Data/Application/" || directory == "/private/var/mobile/Containers/Shared/AppGroup/") {
                                            let plistDict = NSDictionary(contentsOfFile: masterFiles[index].fullPath + ".com.apple.mobile_container_manager.metadata.plist")
                                            let bundleID = defineBundleID(plistDict ?? NSDictionary(dictionaryLiteral: ("MCMMetadatIdentifier", "lol.whitetailani.Spartan"))) //these default values are literally never used but otherwise it crashes when you try and open from favorites for some stupid reason
                                            let groupBundleID = plistDict?["MCMMetadataIdentifier"] as? String ?? "lol.whitetailani.Spartan"
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
                                            switch masterFiles[index].fileType {
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
                                            case 5.9:
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
                                                if(isDirectory(filePath: masterFiles[index].fullPath)) {
                                                    Text(removeLastChar(masterFiles[index].name))
                                                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                        }
                                                } else {
                                                    Text(masterFiles[index].name)
                                                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                        }
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
											case 12:
												Image(systemName: "photo.fill")
												Text(masterFiles[index].name)
                                                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                    }
											case 13:
												Image(systemName: "externaldrive")
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
                            newViewFileName = masterFiles[newViewFileIndex].name
                            showSubView[3] = true
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
                            
                            AVFileOpener //3 rows
                            
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
									showSubView[31] = true
								}
							}) {
								Text(NSLocalizedString("OPEN_DMG", comment: ""))
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
							
							DpkgFileOpener //2 rows
							
							Button(action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[32] = true
								}
							}) {
								Text(NSLocalizedString("OPEN_DMG", comment: ""))
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
                            fileInfo = getFileInfo(forFileAtPath: directory + newViewFileName) //this is more early mystery code. how does it work? i dunno. is it bad? probably. am i going to mess with it? no, because it works.
                        }
                    }
                }
                .sheet(isPresented: $showSubView[27], onDismiss: {
                    showSubView[3] = true
                }, content: {
                    TextField(NSLocalizedString("PERMSEDIT", comment: "This should have been added a long time ago"), value: $filePerms, formatter: NumberFormatter(), onCommit: {
                        changeFilePerms(filePath: masterFiles[newViewFileIndex].fullPath, permValue: filePerms)
                        showSubView[27] = false
                    })
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode) //it does some number filtering i think?
                    .onAppear {
						do {
							filePerms = try fileManager.attributesOfItem(atPath: masterFiles[newViewFileIndex].fullPath)[.posixPermissions] as? Int ?? 640 //this used to be a 000 for some reason??????? i changed it to 640 like other files on the tvOS filesystem. truly amazing.
                        } catch {
							filePerms = 000
						}//it also used a try! for some reason, so that's changed as well.
                    }
                })
				//welcome to the SheetStack. how anything and everything is presented: a bool in showSubView, and a sheet.
				//there's a lot. most of them are pretty easy to comprehend, if there's anything out of the ordinary I'll explain it
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
							masterFiles.append(SpartanFile(name: URL(fileURLWithPath: newViewFilePath).lastPathComponent, fullPath: newViewFilePath, isSelected: false, fileType: yandereDevFileType(file: newViewFilePath), isLoadingFile: false))
                            defaultAction(index: masterFiles.count-1, isDirectPath: false)
                        }
                        didSearch = false
                    }
                }, content: {
                    SearchView(directory: $directory, isPresenting: $showSubView[19], selectedFile: $newViewFilePath, didSearch: $didSearch)
                }) //my search function is very complex and i'm not sure how I wrote it. i don't fully understand it now and i didn't understand it then, either. I know it works and so im happy
                //someday I'll figure it out. It's surprisingly good
                .sheet(isPresented: $showSubView[6], content: {
                    CreateDirectoryView(directoryPath: $directory, isPresented: $showSubView[6])
                })
                .sheet(isPresented: $showSubView[5], content: {
                    CreateFileView(filePath: $directory, isPresented: $showSubView[5])
                })
                .sheet(isPresented: $showSubView[20], content: {
                    CreateSymlinkView(symlinkPath: $directory, isPresented: $showSubView[20])
                })
                .sheet(isPresented: $showSubView[16], onDismiss: {
                    updateFiles() //FavoritesView *can* change directory, but without an updateFiles the changes won't be reflected. it took me awhile to figure this bug out.
                }, content: {
                    FavoritesView(directory: $directory, showView: $showSubView[16])
                })
                .sheet(isPresented: $showSubView[17], content: {
                    AddToFavoritesView(filePath: newViewFilePath, displayName: newViewFileName, showView: $showSubView[17])
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
                .sheet(isPresented: $showSubView[12], onDismiss: {
					isImageSVG = false
                }, content: {
                    ImageView(imagePath: newViewFilePath, imageName: newViewFileName, isSVG: isImageSVG)
                })
                .sheet(isPresented: $showSubView[13], content: {
                    PlistView(filePath: newViewFilePath, fileName: newViewFileName)
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
                        } //it can take a long time for my current hex editor implementation to load everything, so a loading circle is displayed. i typically avoid it for this reason.
                        //i will later improve it, I just don't like working with Data
                })
                .sheet(isPresented: $showSubView[23], content: {
                    DpkgView(debPath: $newViewFilePath, debName: $newViewFileName, isPresented: $showSubView[23], isRootless: $isRootless)
                })
                .sheet(isPresented: $showSubView[24], content: {
                    DpkgBuilderView(debInputDir: $newViewFilePath, debInputName: $newViewFileName, isPresented: $showSubView[24], isRootless: $isRootless)
                }) //i created these in case anything with nitoTV breaks. having filza deb installer has saved my butt more times than I can count
                .sheet(isPresented: $showSubView[25], content: {
                    WebServerView() //this will probably never work
                })
                .sheet(isPresented: $showSubView[28], content: {
                    CarView(filePath: $newViewFilePath, fileName: $newViewFileName)
                })
                .sheet(isPresented: $showSubView[30], content: {
                    FontView(filePath: $newViewFilePath, fileName: $newViewFileName) //i was bored i think
                })
				.sheet(isPresented: $showSubView[32], content: {
					DMGMountView(filePath: newViewFilePath, fileName: newViewFileName, directory: $directory, isPresented: $showSubView[32])
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
        .onPlayPauseCommand {
			callback = false
			showSubView[10] = true
		} //this lets you access the music player from anywhere. it does create a new instance of the view, but it's accessing the same AV player always, so it never loses its place. it doesn't break when you open it without a music file loaded, too - that took far too long
        .onExitCommand {
            if(directory == "/"){
                ObjCFunctions.suspendNow() //an objc function. the first bit of objc I wrote.
                //i have written a lot more for Alcatraz, but it's so ugly and annoying. i do not like using it
            } else {
                goBack()
            }
        } //this handles going back directories with the menu button.
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
                if (multiSelect) { //multiselect is a robust feature. the issue I had the most trouble with was with updateFiles, since the number of files would change but my multiselect array was too long. so I had to work out resizing the array.
                //i gave up on that, and I just reset it to [] and then the length of masterFiles. it works.
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
                
                Button(action: {
					showSubView[21] = true
				}) {
					Image(systemName: "externaldrive")
						.frame(width:50, height:50)
				}
                
                /*if #available(tvOS 14.0, *) {
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
                }*/
                //this is the webserver button
                
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
                            .frame(width: 50, height: 50)
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 15, height: 13)
                            .offset(x: -4, y: 11.75) //i do not know how i came up with these values. i am not going to touch them. hopefully it doesn't break on non-1080p (i don't have this)
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
            $0[HorizontalAlignment.center] //i do not know what this is doing, i'm not messing with it. it most likely has a purpose
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    @ViewBuilder
    var serverButton: some View {
        if #unavailable(tvOS 16.0) { //i... don't know why this is here? the webserver stuff can't be loaded by the UI, so i'm ignoring it for now. i'm curious what this was done for
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
            //start webserver headless
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
		//future me wants you to know it works now but im not changing it.
        let (doubleValue, stringValue) = freeSpace(path: "/")
        return
            Text(NSLocalizedString("FREE_SPACE", comment: "E") + String(format: "%.2f", doubleValue) + " " + stringValue)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 32)
                }
        .alignmentGuide(.trailing) {
            $0[HorizontalAlignment.trailing]
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var debugMenu: some View {
        return VStack {
			if E { //i need e
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
            showSubView[31] = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showSubView[2] = false
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
        .alert(isPresented: $showSubView[31], content: {
			Alert(
				title: Text(""),
				message: Text(NSLocalizedString("INFO_DENIED", comment: "You're monsters!")),
				primaryButton: .default(Text(LocalizedString("OPEN_IMAGERGBA")), action: {
					isImageSVG = false
				}),
				secondaryButton: .default(Text(LocalizedString("OPEN_IMAGESVG")), action: {
					isImageSVG = true
				})
			)
		})
		.onDisappear {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showSubView[12] = true
            }
		}
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
    
    func defaultAction(index: Int, isDirectPath: Bool) { //this function was created to allow tvOS 13 support. it is probably the most important function in this entire file manager. without it, nothing works
        var fileToCheck: [String] = masterFiles.map { $0.name }
        if(isDirectPath) {
            fileToCheck = [""]
        }
    
        if (multiSelect) {
            if(masterFiles[index].isSelected){
                let searchedIndex = multiSelectFiles.firstIndex(of: masterFiles[index].name)
                multiSelectFiles.remove(at: searchedIndex!)
                masterFiles[index].isSelected = false
            } else {
                masterFiles[index].isSelected = true
                multiSelectFiles.append(masterFiles[index].name)
            }
        } else {
            multiSelect = false
            newViewFilePath = directory
            newViewFileName = fileToCheck[index]
            let fileType = Int(yandereDevFileType(file: (directory + fileToCheck[index])))
            switch fileType {
            case 0:
                do {
                    try fileManager.contentsOfDirectory(atPath: directory + fileToCheck[index])
                } catch {
                    if(substring(str: error.localizedDescription, startIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: -33), endIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: 0)) == "don’t have permission to view it.") { //substrings are horrible parts of swift
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
                let dest = readSymlinkDestination(path: directory + fileToCheck[index])
                if(isDirectory(filePath: dest)) {
                    directory = dest
                } else {
					masterFiles.append(SpartanFile(name: URL(fileURLWithPath: dest).lastPathComponent, fullPath: dest, isSelected: false, fileType: Double(fileType), isLoadingFile: false))
                    defaultAction(index: masterFiles.count-1, isDirectPath: false)
                }
                updateFiles()
            case 9:
                showSubView[23] = true
            case 10:
                showSubView[28] = true
            case 11:
                showSubView[30] = true
			case 12:
				isImageSVG = true
				showSubView[12] = true
			case 13:
				showSubView[32] = true
            default:
                masterFiles[index].isLoadingFile = true
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
                masterFiles.append(SpartanFile(name: files[i], fullPath: directory + files[i], isSelected: false, fileType: yandereDevFileType(file: directory + files[i]), isLoadingFile: false))
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
        
        if components.count > 1 {
            components.removeLast()
            directory = "/" + components.joined(separator: "/") + "/"
            if (directory == "//"){
                directory = "/"
            } //there's definitely a better way to do this, but I don't know it and this solution works
        } else {
            directory = "/"
        }
        multiSelect = false
        updateFiles()
    }
    
    func deleteFile(atPath: String) {
        spawn(command: helperPath, args: ["rm", atPath], env: [], root: true) // yee
    }
    
    func getFileInfo(forFileAtPath: String) -> [String] {
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
        spawn(command: helperPath, args: ["mv", path, newPath], env: [], root: true)
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
            print("Error: \(error)")
            return (0, "?")
        }
    }
    func convertBytes(bytes: Double) -> (Double, String) {
        let units = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB", "BB"] //i added support for brontobytes because i could. deal with it
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
        
        //FUTURE ME WANTS YOU TO KNOW I AM TALKING ABOUT THE IF ELSE STACK POST NOT THE PEDO STUFF
        
        let archiveTypes: [String] = ["zip", "cbz"]
        let fontTypes: [String] = ["ttf", "otf", "ttc", "pfb", "pfa"]
        
        if (isSymlink(filePath: file)) {
            return 8 //symlink
        } else if (isDirectory(filePath: file)) {
            return 0 //directory
        } else if (isVideo(filePath: file)) { //video has to come first as otherwise video files detect as audio (since they are audio files as well)
            return 2 //video file
        } else if (isAudio(filePath: file)) {
            return 1 //audio file
        } else if (isImage(filePath: file)) {
            return 3 //image
        } else if (isPlist(filePath: file) != 0) {
            return isPlist(filePath: file)
            //5.1 = xml plist
            //5.9 = bplist
		} else if (isDMG(filePath: file)) {
			return 13 //dmg
		} else if (isSVG(filePath: file)) {
			return 12 //svg
        } else if (fontTypes.contains(where: file.hasSuffix)) {
            return 11 //a font (badly)
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
    func isAudio(filePath: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVAsset(url: fileURL)
        let playableKey = "playable"

        let playablePredicate = NSPredicate(format: "%K == %@", playableKey, NSNumber(value: true))
        let playableItems = asset.tracks(withMediaCharacteristic: .audible).filter { playablePredicate.evaluate(with: $0) }

        return playableItems.count > 0
    }
    func isVideo(filePath: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVAsset(url: fileURL)
        let playableKey = "playable"

        let playablePredicate = NSPredicate(format: "%K == %@", playableKey, NSNumber(value: true))
        let playableItems = asset.tracks(withMediaCharacteristic: .visual).filter { playablePredicate.evaluate(with: $0) }

        return playableItems.count > 0
    }
    func isImage(filePath: String) -> Bool {
        guard fileManager.fileExists(atPath: filePath) else {
            return false
        }
    
        if let image = UIImage(contentsOfFile: filePath) {
            return image.size.width > 0 && image.size.height > 0
        }
        return false
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
        
        if let header = String(data: data.subdata(in: 0..<5), encoding: .utf8) {
            if header == "<?xml" {
                return 5.1
            } else if header == "bplis" {
                return 5.9
            }
        }
        return 0
    }
    func isSymlink(filePath: String) -> Bool {
        let fileURL = URL(fileURLWithPath: filePath)
        
        if directory == "/sbin/" {
            return readSymlinkDestination(path: filePath) == filePath ? true : false
        } else {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.isSymbolicLinkKey])
                if let isSymbolicLink = resourceValues.isSymbolicLink {
                    return isSymbolicLink
                }
            } catch {
                print("Error: \(error)")
            }
        }
        return false
    }
    func isCar(filePath: String) -> Bool {
        guard let data = fileManager.contents(atPath: filePath) else {
            return false
        }
        if data.count > 8 {
			if let header = String(data: data.subdata(in: 0..<8), encoding: .utf8) {
				return header == "BOMStore"
			}
		}
		return false
    }
    func isSVG(filePath: String) -> Bool {
		
        return false
	}
	func isDMG(filePath: String) -> Bool {
		return String(substring(str: filePath, startIndex: filePath.index(filePath.endIndex, offsetBy: -4), endIndex: filePath.index(filePath.endIndex, offsetBy: 0))) == ".dmg"
			
	}
    
    func readSymlinkDestination(path: String) -> String {
        let url = URL(fileURLWithPath: path)
        var dest = url.resolvingSymlinksInPath().path
        
        if(isDirectory(filePath: dest)) {
            dest += "/"
        }
        
        dest = varFixup(dest)
        
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
    
    func directPathTypeCheckNewViewFileVariableSetter() { //this function name is very very silly and im leaving it. I think it's used once and it doesn't even work properly. but it uses a feature that literally no one should be using
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
        
        spawn(command: helperPath, args: ["ch", filePath, String(permValue)], env: [], root: true)
    }
    
    func defineBundleID(_ plistDict: NSDictionary) -> String {
        if (directory == "/private/var/mobile/Containers/Shared/AppGroup/") {
            return trimGroupBundleID(plistDict["MCMMetadataIdentifier"] as? String ?? "group.com.apple.mail") ?? "com.whitetailani.Spartan"
        } else {
            return plistDict["MCMMetadataIdentifier"] as? String ?? "lol.whitetailani.Spartan"
        }
    }
    
    func trimGroupBundleID(_ string: String) -> String? {
        let components = string.components(separatedBy: ".")
        guard components.count >= 3 else {
            return nil
        }
        return components.suffix(3).joined(separator: ".")
    }
    
    func varFixup(_ path: String) -> String {
        if (path.count >= 5 && substring(str: path, startIndex: path.index(path.startIndex, offsetBy: 0), endIndex: path.index(path.startIndex, offsetBy: 5)) == "/var/") {
            return "/private/var/" + substring(str: path, startIndex: path.index(path.startIndex, offsetBy: 5), endIndex: path.index(path.endIndex, offsetBy: 0))
        } //i dont have a way to check if every part of a filepath is a symlink but that doesn't matter. all that matters is that /var/ always becomes /private/var/
        return path
    }
}

struct SpartanFile {
    var name: String
    var fullPath: String
    var isSelected: Bool
    var fileType: Double
    var isLoadingFile: Bool
} // i am so glad I switched to this instead of having like five different arrays
