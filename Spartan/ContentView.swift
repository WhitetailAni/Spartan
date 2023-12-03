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
import SVGWrapper

struct ContentView: View {
    @State var directory: String
    @State private var fileInfo: [String] = []
    @State var deleteOverride = false
    @State var E = false
    @State var E2 = false
    @State var masterFiles: [SpartanFile] = []
    @State var isRootless: Bool
    
    @State var scaleFactor: CGFloat
    @State var buttonCalc = false
    
    @State var didSearch = false
    
    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertMsg = ""
    
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
    
    @State var didChangeDir = false
    
    @State private var showSubView: [Bool] = [Bool](repeating: false, count: 35)
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
    //compFileShow = 14
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
    //htmlViewShow = 33
    //uncompFileShow = 34
    
    @Binding var globalAVPlayer: AVPlayer //this is because Spartan has the ability to play music without the AudioPlayerView being shown. It took about a week to get working properly and I'm proud of it
    @State var isGlobalAVPlayerPlaying = false
    @State var callback = true
    
    //@Binding var webServer: GCDWebUploader
    
    @State private var isLoadingView = false
    @State var blankString: [String] = [""] //dont question it
    @State private var nonexistentFile = "" //REALLY dont question it
    
    @State private var isImageSVG: [Bool] = [false, false]
    
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
                    }
                    
                    Button(action: {
                        updateFiles()
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .sheet(isPresented: $showSubView[6], content: {
                        CreateDirectoryView(directoryPath: $directory, isPresented: $showSubView[6])
                    })
                    .sheet(isPresented: $showSubView[5], content: {
                        CreateFileView(filePath: $directory, isPresented: $showSubView[5])
                    })
                    .sheet(isPresented: $showSubView[20], content: {
                        CreateSymlinkView(symlinkPath: $directory, isPresented: $showSubView[20])
                    })
                }
                HStack {
                    debugMenu
                        .frame(alignment: .leading)
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
                                        .frame(width: 50, height: 50)
                                } else {
                                    Image(systemName: "circle")
                                        .frame(width: 50, height: 50)
                                }
                            } else {
                                Image(systemName: "checkmark.circle")
                                    .frame(width: 50, height: 50)
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
                            .sheet(isPresented: $showSubView[19], onDismiss: {
                                if(didSearch) {
                                    if(FileInfo.isDirectory(filePath: newViewFilePath)) {
                                        directory = newViewFilePath
                                    } else {
                                        directory = URL(fileURLWithPath: newViewFilePath).deletingLastPathComponent().path + "/"
                                        masterFiles.append(SpartanFile(name: URL(fileURLWithPath: newViewFilePath).lastPathComponent, fullPath: newViewFilePath, isSelected: false, fileType: FileInfo.yandereDevFileType(file: newViewFilePath), isLoadingFile: false))
                                        defaultAction(index: masterFiles.count-1, isDirectPath: false)
                                    }
                                    didSearch = false
                                }
                            }, content: {
                                SearchView(directory: $directory, isPresenting: $showSubView[19], selectedFile: $newViewFilePath, didSearch: $didSearch)
                            }) //my search function is very complex and i'm not sure how I wrote it. i don't fully understand it now and i didn't understand it then, either. I know it works and so im happy
                            //someday I'll figure it out. It's surprisingly good
                    
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
                            .sheet(isPresented: $showSubView[21], onDismiss: {
                                if didChangeDir {
                                    updateFiles()
                                    resetShowSubView()
                                    didChangeDir = false
                                }
                            }, content: {
                                MountPointsView(directory: $directory, isPresented: $showSubView[21], didChangeDir: $didChangeDir)
                            })
                            
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
                            .sheet(isPresented: $showSubView[16], onDismiss: {
                                updateFiles() //FavoritesView *can* change directory, but without an updateFiles the changes won't be reflected. it took me awhile to figure this bug out.
                            }, content: {
                                FavoritesView(directory: $directory, showView: $showSubView[16])
                            })
                            .sheet(isPresented: $showSubView[17], content: {
                                AddToFavoritesView(filePath: newViewFilePath, displayName: newViewFileName, showView: $showSubView[17])
                            })
                        
                            Button(action: { //settings
                                showSubView[18] = true
                            }) {
                                Image(systemName: "gear")
                                    .frame(width:50, height:50)
                            }
                            .sheet(isPresented: $showSubView[18], content: {
                                SettingsView()
                            })
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
                                newViewFilePath = directory
                                newViewArrayNames = multiSelectFiles
                            }) {
                                Image(systemName: "doc.zipper")
                                    .frame(width:50, height:50)
                            }
                        
                            Button(action: {
                                if(directory == "/private/var/mobile/Media/.Trash/"){
                                    for file in multiSelectFiles {
                                        RootHelperActs.rm(directory + file)
                                        updateFiles()
                                    }
                                } else {
                                    for file in multiSelectFiles {
                                        RootHelperActs.mv(directory + file, "/private/var/mobile/Media/.Trash/" + file)
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
                    .frame(alignment: .center)
                    
                    freeSpace
                        .frame(alignment: .trailing)
                        .sheet(isPresented: $showSubView[15], content: {
                            SpawnView(filePath: $newViewFilePath, fileName: $newViewFileName, isPresented: $showSubView[15])
                        })
                        .sheet(isPresented: $showSubView[4], content: {
                            TextView(filePath: newViewFilePath, fileName: newViewFileName, isPresented: $showSubView[4])
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
                            isImageSVG[0] = false
                        }, content: {
                            ImageView(imagePath: newViewFilePath, imageName: newViewFileName, isSVG: isImageSVG[0])
                        })
                        .sheet(isPresented: $showSubView[13], content: {
                            PlistView(filePath: newViewFilePath, fileName: newViewFileName)
                        })
                        .sheet(isPresented: $showSubView[14], onDismiss: {
                            updateFiles()
                        }, content: {
                            CompressFileView(isPresented: $showSubView[14], directory: directory, fileNames: multiSelectFiles, multipleFiles: (multiSelectFiles.count > 1))
                        })
                        .sheet(isPresented: $showSubView[34], onDismiss: {
                            updateFiles()
                        }, content: {
                            UncompressFileView(isPresented: $showSubView[34], filePath: newViewFilePath, fileName: newViewFileName)
                        })
                        .sheet(isPresented: $showSubView[22], content: {
                            HexView(filePath: newViewFilePath, fileName: newViewFileName, isPresented: $showSubView[22])
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
                        .sheet(isPresented: $showSubView[33], content: {
                            HTMLView(filePath: newViewFilePath, fileName: newViewFileName)
                        })
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
                                
                                Button(action: {
                                    RootHelperActs.rm(directory + metadataName!)
                                }) {
                                    Text(localizedString: "CACHE_CLEAR")
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
                                                        if (FileInfo.isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 1) {
                                                            Image(systemName: "folder")
                                                        } else if (FileInfo.isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 0) {
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
                                                        let bundleID = defineBundleID(plistDict ?? NSDictionary(dictionaryLiteral: ("MCMMetadataIdentifier", "com.whitetailani.Spartan"))) //these optionals are literally never used but otherwise it crashes when you try and open from favorites so L
                                                        let groupBundleID = plistDict?["MCMMetadataIdentifier"] as? String ?? "com.whitetailani.Spartan"
                                                        //in every container folder (whether it's the bundle container, data container, or group container) is a file that contains the app's bundle ID. santander macros do support determining an LSApplicationProxy? from bundle/container/data container folder on **iOS** but not tvOS since sandboxing system is different. Reading from bundle ID ensures that the app definitely exists and someone didn't just create a folder in here, so no issues with nil LSApplicationProxy? elements
                                                        //then the rest of this just reads properties from the LSApplicationProxy.
                                                        
                                                        //viewing app icons broke at some point though. not sure why
                                                        
                                                        let app = LSApplicationProxy(forIdentifier: bundleID)
                                                        HStack {
                                                            let image: UIImage? = appsManager.icon(forApplication: app)
                                                            if(image != nil) {
																Image(uiImage: (image ?? UIImage(named: "DefaultIcon"))!)
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
                                                        if (FileInfo.isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 1) {
                                                            Image(systemName: "folder")
                                                        } else if (FileInfo.isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 0) {
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
                                                    if (FileInfo.isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 1) {
                                                        Image(systemName: "folder")
                                                    } else if (FileInfo.isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 0) {
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
                                                if(FileInfo.isDirectory(filePath: masterFiles[index].fullPath)) {
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
											case 14:
												Image(systemName: "safari")
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
                                        newViewFilePath = directory
                                        newViewArrayNames = [masterFiles[index].name]
                                        newViewFileIndex = index
                                        showSubView[2] = true
                                    }) {
                                        Text(NSLocalizedString("OPENIN", comment: "The bee, of course, flies anyway"))
                                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                            }
                                    }
                                    
                                    if(directory == "/private/var/mobile/Media/.Trash/"){
                                        Button(action: {
                                            RootHelperActs.rm(masterFiles[index].fullPath)
                                            masterFiles.remove(at: index)
                                        }) {
                                            Text(NSLocalizedString("DELETE", comment: "because bees don't care what humans think is impossible."))
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
                                        }
                                    } else if (directory == "/private/var/mobile/Media/" && masterFiles[index].name == ".Trash/") {
                                        Button(action: {
                                            RootHelperActs.rm("/private/var/mobile/Media/.Trash/")
                                            RootHelperActs.mkdir("/private/var/mobile/Media/.Trash/")
                                            updateFiles()
                                        }) {
                                            Text(NSLocalizedString("TRASHYEET", comment: "Yellow, black. Yellow, black."))
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
                                        }
                                    } else {
                                        Button(action: {
                                            RootHelperActs.mv(masterFiles[index].fullPath, ("/private/var/mobile/Media/.Trash/" + masterFiles[index].name))
                                            masterFiles.remove(at: index)
                                        }) {
                                            Text(NSLocalizedString("GOTOTRASH", comment: "Yellow, black. Yellow, black."))
                                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                                    view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                                                }
                                        }
                                    }
                                    if(deleteOverride) { //this never activates, but I leave it in just in case I ever change how this works
                                        Button(action: {
                                            RootHelperActs.rm(masterFiles[index].fullPath)
                                            masterFiles.remove(at: index)
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
                            
                            //future me wants you to know that i *still* don't really test this. i bought a TV HD to put on 13.4.8 but it came on 14.7 and signed into hulu and prime video so im not downgrading it since i also need a 14 test device (my 14.3 tv 4k 1st gen doesn't work since it won't enter dfu and thus won't jb)
                            
                            //most of the code is actually just copy and pasted, so older comments are duplicated as well. i just changed how it's handled slightly
                                Button(action: {
                                    newViewFilePath = directory
                                    newViewFileName = masterFiles[index].name
                                    newViewFileIndex = index
                                    showSubView[1] = true
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
                                            let bundleID = defineBundleID(plistDict ?? NSDictionary(dictionaryLiteral: ("MCMMetadataIdentifier", "com.whitetailani.Spartan"))) //these default values are literally never used but otherwise it crashes when you try and open from favorites for some stupid reason
                                            let groupBundleID = plistDict?["MCMMetadataIdentifier"] as? String ?? "com.whitetailani.Spartan"
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
                                                if (FileInfo.isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 1) {
                                                    Image(systemName: "folder")
                                                } else if (FileInfo.isDirectoryEmpty(atPath: masterFiles[index].fullPath) == 0) {
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
                                                if(FileInfo.isDirectory(filePath: masterFiles[index].fullPath)) {
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
											case 14:
												Image(systemName: "safari")
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
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text(alertTitle),
                                message: Text(alertMsg),
                                dismissButton: .default(Text(NSLocalizedString("DISMISS", comment: "You're sky freaks! I love it! I love it!")))
                            )
                        }
                    }
                }
                .sheet(isPresented: $showSubView[1]) {
					ContextMenuButtonTV(stringKey: "OPEN", action: {
						defaultAction(index: newViewFileIndex, isDirectPath: false)
                        showSubView[1] = false
					}) //i got tired of having the same copy pasted button thing so I made it a wrapper struct with only the parameters I need. cut down on filesize a lot
					
					ContextMenuButtonTV(stringKey: "INFO", action: {
                        fileInfo = FileInfo.getFileInfo(filePath: masterFiles[newViewFileIndex].fullPath)
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            newViewFileName = masterFiles[newViewFileIndex].name
                            showSubView[3] = true
                        }
					})
					
					ContextMenuButtonTV(stringKey: "RENAME", action: {
                        newViewFilePath = directory
                        renameFileCurrentName = masterFiles[newViewFileIndex].name
                        renameFileNewName = masterFiles[newViewFileIndex].name
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSubView[7] = true
                        }
                    })
                    
                    ContextMenuButtonTV(stringKey: "OPENIN", action: {
                        newViewFilePath = directory
                        newViewArrayNames = [masterFiles[newViewFileIndex].name]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSubView[2] = true
                        }
                    })
                    
                    if(directory == "/private/var/mobile/Media/.Trash/"){
                        ContextMenuButtonTV(stringKey: "DELETE", action: {
                            RootHelperActs.rm(masterFiles[newViewFileIndex].fullPath)
                            masterFiles.remove(at: newViewFileIndex)
                            showSubView[1] = false
                        })
                    } else if(directory == "/private/var/mobile/Media/" && masterFiles[newViewFileIndex].name == ".Trash/"){
                        ContextMenuButtonTV(stringKey: "TRASHYEET", action: {
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
                        })
                    } else {
                        ContextMenuButtonTV(stringKey: "GOTOTRASH", action: {
                            RootHelperActs.mv(masterFiles[newViewFileIndex].fullPath, ("/private/var/mobile/Media/.Trash/" + masterFiles[newViewFileIndex].name))
                            masterFiles.remove(at: newViewFileIndex)
                            showSubView[1] = false
                        })
                    }
                    if(deleteOverride) { //i dont think this can display but it's HERE ANYWAY
                        ContextMenuButtonTV(stringKey: "DELETE", action: {
                            RootHelperActs.rm(masterFiles[newViewFileIndex].fullPath)
                            masterFiles.remove(at: newViewFileIndex)
                            showSubView[1] = false
                        })
                    }
                    
                    ContextMenuButtonTV(stringKey: "FAVORITESADD", action: {
                        newViewFilePath = directory
						newViewFileName = masterFiles[newViewFileIndex].name
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSubView[17] = true
                        }
                        UserDefaults.favorites.synchronize()
                    })//I'm sticking to consistent setups that I've practiced
                    
                    ContextMenuButtonTV(stringKey: "MOVETO", action: {
                        newViewFilePath = directory
                        newViewArrayNames = [masterFiles[newViewFileIndex].name]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSubView[8] = true
                        }
                    })
                    
                    
                    ContextMenuButtonTV(stringKey: "COPYTO", action: {
                        newViewFilePath = directory
                        newViewArrayNames = [masterFiles[newViewFileIndex].name]
                        showSubView[1] = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showSubView[9] = true
                        }
                    })
                    
                    
                    ContextMenuButtonTV(stringKey: "DISMISS", action: {
                        showSubView[1] = false
                    })
                }
                .sheet(isPresented: $showSubView[2]) {
                    HStack {
                        VStack {
                            ContextMenuButtonTV(stringKey: "OPEN_DIRECTORY", action: {
                                directory = directory + masterFiles[newViewFileIndex].name
                                updateFiles()
                                showSubView[2] = false
                            })
                            
                            ContextMenuButtonTV(stringKey: "OPEN_AUDIO", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[10] = true
									callback = true
								}
							})
							
							
							ContextMenuButtonTV(stringKey: "OPEN_VIDEO", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[11] = true
								}
							})
							
							
							ContextMenuButtonTV(stringKey: "OPEN_IMAGE", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								isImageSVG[1] = true
								showSubView[31] = true
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[2] = false
								}
							})
							.onDisappear {
								if isImageSVG[1] {
									DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
										showSubView[12] = true
									}
								}
							}
							.alert(isPresented: $showSubView[31], content: {
								Alert(
									title: Text(""),
									message: Text(NSLocalizedString("INFO_DENIED", comment: "You're monsters!")),
                                    primaryButton: .default(Text(localizedString: "OPEN_IMAGERGBA"), action: {
										isImageSVG[0] = false
									}),
                                    secondaryButton: .default(Text(localizedString: "OPEN_IMAGESVG"), action: {
										isImageSVG[0] = true
									})
								)
							})
                            
                            ContextMenuButtonTV(stringKey: "OPEN_TEXT", action: {
                                newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
                                showSubView[2] = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showSubView[4] = true
                                }
                            })
                            
                            ContextMenuButtonTV(stringKey: "OPEN_HEX", action: {
                                newViewFilePath = directory
                                newViewFileName = masterFiles[newViewFileIndex].name
                                showSubView[2] = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showSubView[22] = true
                                }
                            })
                            
                            ContextMenuButtonTV(stringKey: "OPEN_DMG", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[32] = true
								}
							})
                            
                            ContextMenuButtonTV(stringKey: "OPEN_COMP", action: {
                                newViewFilePath = directory
                                newViewArrayNames = [masterFiles[newViewFileIndex].name]
                                showSubView[2] = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showSubView[14] = true
                                }
                            })
                            
                            ContextMenuButtonTV(stringKey: "OPEN_UNCOMP", action: {
                                newViewFilePath = directory
                                newViewFileName = masterFiles[newViewFileIndex].name
                                showSubView[2] = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showSubView[34] = true
                                }
                            })
                        }
                    
						VStack {
                            ContextMenuButtonTV(stringKey: "FAVORITESADD", action: {
                                newViewFilePath = directory
                                newViewFileName = masterFiles[newViewFileIndex].name
                                showSubView[2] = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showSubView[17] = true
                                }
                            })
                            
							ContextMenuButtonTV(stringKey: "OPEN_PLIST", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[13] = true
								}
							})
							
							ContextMenuButtonTV(stringKey: "OPEN_FONT", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[30] = true
								}
							})
							
							ContextMenuButtonTV(stringKey: "OPEN_DPKG", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[23] = true
								}
							})
							
							ContextMenuButtonTV(stringKey: "OPEN_DPKGDEB", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[24] = true
								}
							})
							
							ContextMenuButtonTV(stringKey: "OPEN_HTML", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[33] = true
								}
							})
							
							ContextMenuButtonTV(stringKey: "OPEN_CAR", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[34] = true
								}
							})
							
							ContextMenuButtonTV(stringKey: "OPEN_SPAWN", action: {
								newViewFilePath = directory
								newViewFileName = masterFiles[newViewFileIndex].name
								showSubView[2] = false
								DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
									showSubView[15] = true
								}
							})
							
							ContextMenuButtonTV(stringKey: "DISMISS", action: {
								showSubView[2] = false
							})
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
                    }), showSubView: $showSubView)
                }
                .navigationBarHidden(true)
                .onAppear {
                    resetShowSubView()
                    updateFiles()
                    if(FileInfo.yandereDevFileType(file: directory) != 0) {
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
                            fileInfo = FileInfo.getFileInfo(filePath: directory + newViewFileName) //turns out this is pretty simple. it just asks FileManager for file attributes and formats them
                        }
                    }
                }
                .sheet(isPresented: $showSubView[27], onDismiss: {
                    showSubView[3] = true
                }, content: {
                    TextField(NSLocalizedString("PERMSEDIT", comment: "This should have been added a long time ago"), value: $filePerms, formatter: NumberFormatter(), onCommit: {
                        RootHelperActs.chmod(masterFiles[newViewFileIndex].fullPath, filePerms)
                        showSubView[27] = false
                    })
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode) //0-9 only!
                    .onAppear {
						do {
							filePerms = try fileManager.attributesOfItem(atPath: masterFiles[newViewFileIndex].fullPath)[.posixPermissions] as? Int ?? 000 //this used to be a 000 for some reason??????? i changed it to 640 like other files on the tvOS filesystem. truly amazing.
							//im unsmart and forgot what this does. if it can't read the file perms it sets them to 000 since it can't read the file... and 000 means no perms to read the file........
                        } catch {
							filePerms = 000
						}//it also used a try! for some reason, so that's changed as well.
                    }
                })
				/*
                welcome to the SheetStack. how anything and everything is presented: a bool in showSubView, and a sheet.
				there's a lot. most of them are pretty easy to comprehend, if there's anything out of the ordinary I'll explain it
                
                 they were split apart due to a silly tvOS 14.1-14.4(?) bug. you can find them attached to:
                 1. the button they're called by
                 2. freeSpace by the top of the file
                */
                .sheet(isPresented: $showSubView[0], content: {
                    VStack {
                        ContextMenuButtonTV(stringKey: "CREATE_FILE") {
                            showSubView[0] = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showSubView[5] = true
                            }
                        }
                        
                        ContextMenuButtonTV(stringKey: "CREATE_DIR") {
                            showSubView[0] = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showSubView[6] = true
                            }
                        }
                        
                        ContextMenuButtonTV(stringKey: "CREATE_SYM") {
                            showSubView[0] = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showSubView[20] = true
                            }
                        }
                    }
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
    
    @ViewBuilder
    var serverButton: some View {
        if #unavailable(tvOS 16.0) { //i... don't know why this is here? the webserver stuff can't be loaded by the UI, so i'm ignoring it for now. i'm curious what this was done for
        //I REMEMBER WHY I WAS USING A DIFFERENT SF SYMBOL THAT DOESNT EXIST ON >=16.0
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
    
    @ViewBuilder
    var freeSpace: some View { //this is hardcoded for now, returning mount points wasnt working
		//future me wants you to know it works now but im not changing it.
        let (doubleValue, stringValue) = freeSpace(path: "/")
        Text(NSLocalizedString("FREE_SPACE", comment: "E") + String(format: "%.2f", doubleValue) + " " + stringValue)
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 32)
                }
    }
    
    @ViewBuilder
    var debugMenu: some View {
        VStack {
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
    
    func defaultAction(index: Int, isDirectPath: Bool) { //this function was created to allow tvOS 13 support. it is probably the most important function in this entire file manager. without it, nothing aside from directory listing works
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
            let fileType = masterFiles[index].fileType
            switch fileType {
            case 0:
                do {
                    try fileManager.contentsOfDirectory(atPath: directory + fileToCheck[index])
                } catch {
					let err = error.localizedDescription
					if err.substring(fromIndex: err.count - 33) == "don’t have permission to view it." { //substrings are horrible parts of swift
						//switched to using the String extension. so much nicer.
                        alertTitle = NSLocalizedString("SHOW_DENIED", comment: "Here's the graduate.")
                        alertMsg = NSLocalizedString("INFO_DENIED", comment: "You're monsters!")
                        showAlert = true
                    }
                }
                if(!showAlert){
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
                showSubView[34] = true
            case 7:
                showSubView[15] = true
            case 8:
                do {
                    let dest = try FileInfo.readSymlinkDestination(path: directory + fileToCheck[index])
                    if directory != dest { //1.74/2gb memory used if you have a symlink that resolves to itself. spartan continually tries to resolve to it and it infinite loops until jetsam kills it due to too much memory usage
                        if FileInfo.isDirectory(filePath: dest) {
                            directory = dest
                            updateFiles()
                        } else {
                            masterFiles.append(SpartanFile(name: URL(fileURLWithPath: dest).lastPathComponent, fullPath: dest, isSelected: false, fileType: FileInfo.yandereDevFileType(file: dest), isLoadingFile: false))
                            defaultAction(index: masterFiles.count-1, isDirectPath: false)
                        }
                    }
                } catch {
                    alertTitle = LocalizedString("BADSYMLINK")
                    alertMsg = LocalizedString("BADSYMLINK_MSG")
                    showAlert = true
                    print("Please create a valid symlink. (Error ID 167)")
                }
            case 9:
                showSubView[23] = true
            case 10:
                showSubView[28] = true
            case 11:
                showSubView[30] = true
			case 12:
				isImageSVG[0] = true
				showSubView[12] = true
			case 13:
				showSubView[32] = true
			case 14:
				showSubView[33] = true
            default:
                masterFiles[index].isLoadingFile = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSubView[22] = true
                }
            }
        }
    }

    func updateFiles() { //credit to ethanrdoesmc for the updates to this. now we have a ds_store clone!
        guard fileManager.fileExists(atPath: directory + metadataName!) else {
            masterFiles = oldUpdate()
            print("file didnt exist")
            return
        }
        guard let encoded = fileManager.contents(atPath: directory + metadataName!) else {
            masterFiles = oldUpdate()
            print("file was broke")
            return
        } //two guards. one to make sure the file exists, and one to make sure it has data. if it doesn't exist (directory hasn't been cached yet) or is empty (no files in the folder, would be a waste of time to check it), fallback to the old method (which when a directory is empty, is extremely fast).
        let decoder = JSONDecoder()
        var decoded: [SpartanFile] = []
        do {
            masterFiles = []
            print(metadataName!)
            decoded = try decoder.decode([SpartanFile].self, from: encoded)
            let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
            var files: [String]
            files = contents.map { file in
                let filePath = "/" + directory + "/" + file
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
                return isDirectory.boolValue ? "\(file)/" : file
            }
            if let metadataIndex = files.firstIndex(of: metadataName!) {
                files.remove(at: metadataIndex)
            } //hide the metadata file from view
            for i in 0..<files.count {
                if let j = decoded.map({ $0.name }).firstIndex(of: files[i]) {
                    masterFiles.append(decoded[j])
                } else {
                    masterFiles.append(SpartanFile(name: files[i], fullPath: directory + files[i], isSelected: false, fileType: FileInfo.yandereDevFileType(file: directory + files[i]), isLoadingFile: false))
                }
            }
        } catch {
            masterFiles = oldUpdate()
            print(error)
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) { //removes files that no longer exist from the cache (so the filesize doesn't grow until you run out of disk space)
            var decoded2 = decoded
            for i in 0..<decoded.count {
                if !(masterFiles.contains(decoded[i])) {
                    decoded2.remove(at: i)
                }
            }
            let encoder = JSONEncoder()
            do {
                let encoded = try encoder.encode(decoded2)
                try encoded.write(to: URL(fileURLWithPath: tempPath))
            } catch {
                print("failed to update and/or save cached metadata: \(error)")
            }
            RootHelperActs.mvtemp(directory + metadataName!)
            resetMultiSelectArrays()
        }
        if UserDefaults.settings.bool(forKey: "autoComplete") && !directory.hasSuffix("/") && FileInfo.isDirectory(filePath: directory) {
            directory = directory + "/"
        }
        if directory == "//" {
			directory = "/"
		}
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            cacheFolder(directory)
        }
    }
    
    func oldUpdate() -> [SpartanFile] {
        var new: [SpartanFile] = []
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
            var files: [String]
            files = contents.map { file in
                let filePath = "/" + directory + "/" + file
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
                return isDirectory.boolValue ? "\(file)/" : file
            }
            if let metadataIndex = files.firstIndex(of: metadataName!) {
                files.remove(at: metadataIndex)
            } //hide the metadata file from view
            for i in 0..<contents.count {
                new.append(SpartanFile(name: files[i], fullPath: directory + files[i], isSelected: false, fileType: FileInfo.yandereDevFileType(file: directory + files[i]), isLoadingFile: false))
            }
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(new)
            try encoded.write(to: URL(fileURLWithPath: tempPath))
            RootHelperActs.mvtemp(directory + metadataName!)
        } catch {
            print(error.localizedDescription)
        }
        return new
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
    
    func freeSpace(path: String) -> (double: Double, string: String) {
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
        let units = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB", "BB"] //i added support for anything > gigabytes because i could. deal with it. maybe someday i'll add support for mounting external storage, so it could come in handy. you never know
        //or maybe dosdude1 will just chuck a bunch of storage in an atv
        var remainingBytes = Double(bytes)
        var i = 0
        
        while remainingBytes >= 1024 && i < units.count - 1 {
            remainingBytes /= 1024
            i += 1
        }
        
        return (remainingBytes, units[i])
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
        if(FileInfo.yandereDevFileType(file: directory) != 0){
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
    
    func defineBundleID(_ plistDict: NSDictionary) -> String {
        if (directory == "/private/var/mobile/Containers/Shared/AppGroup/") {
            return trimGroupBundleID(plistDict["MCMMetadataIdentifier"] as? String ?? "group.com.apple.mail") ?? "com.whitetailani.Spartan"
        } else {
            return plistDict["MCMMetadataIdentifier"] as? String ?? "com.whitetailani.Spartan"
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

struct SpartanFile: Hashable, Encodable, Decodable {
    var name: String
    var fullPath: String
    var isSelected: Bool
    var fileType: Double
    var isLoadingFile: Bool
} // i am so glad I switched to this instead of having like five different arrays
