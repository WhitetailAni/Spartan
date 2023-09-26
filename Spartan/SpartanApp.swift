//
//  SpartanApp.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
@_exported import LaunchServicesBridge

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    @State var directoryToLoad: String = ""
    
    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? [NSLocalizedString("NOFAVORITES", comment: "The Bee Movie Script Will Be Located In NSLocalizedString Comments")])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/private/var/mobile/Media/.Trash/"])
    
    @State private var buttonWidth: CGFloat = 0
    @State private var buttonHeight: CGFloat = 0
    
    let fileManager = FileManager.default
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UserDefaults.settings.set(false, forKey: "haveLaunchedBefore")
    
        if(!UserDefaults.settings.bool(forKey: "haveLaunchedBefore")) {
            UserDefaults.settings.set(25, forKey: "logWindowFontSize")
            UserDefaults.settings.set(true, forKey: "autoComplete")
            UserDefaults.settings.set(true, forKey: "haveLaunchedBefore")
            UserDefaults.settings.synchronize()
        }
        
        #if DEBUG
            spawn(command: "/private/var/containers/Bundle/Application/RootHelper", args: ["ch", helperPath, String(755)], env: [], root: true)
        #endif
        RootHelperActs.chmod(String(Bundle.main.bundlePath + "/clutch"), 755)
        spawn(command: "/private/var/containers/Bundle/Application/RootHelper", args: ["ch", helperPath, String(755)], env: [], root: true)
        
        
        if(fileManager.isReadableFile(atPath: "/private/var/mobile/")){ //shows app data directory if sandbox exists
            displayView(pathToLoad: "/private/var/mobile/Documents/")
            //displayView(pathToLoad: Bundle.main.bundlePath)
            //displayView(pathToLoad: "/private/var/containers/Bundle/Application/2A65A51A-4061-4143-B622-FA0E57C0C3EE/trillstore.app/")
        } else {
            displayView(pathToLoad: "/Developer/")
        }
        
        createTrash()
        
        return true
    }
    
    func displayView(pathToLoad: String) {
        let isRootless = {
            if(fileManager.fileExists(atPath: "/private/var/jb/")) {
                return true
            }
            return false
        }()
        let hostingController = UIHostingController(rootView: ContentView(directory: pathToLoad, isRootless: isRootless, scaleFactor: UIScreen.main.nativeBounds.height/1080))
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = hostingController
            window?.makeKeyAndVisible()
    }
    
    func createTrash() {
        if(!(fileManager.fileExists(atPath: "/private/var/mobile/Media/.Trash"))){
            do {
                try createDirectoryAtPath(path: "/private/var/mobile/Media", directoryName: ".Trash")
                print("Created trash directory")
            } catch {
                print("Failed to create trash")
            }
        } else {
            print("Trash already exists")
        }
    }
    
    func createDirectoryAtPath(path: String, directoryName: String) throws {
        guard fileManager.fileExists(atPath: "/private/var/mobile/Media/.Trash/") else {
            print("Trash already exists")
            return
        }
        let directoryPath = (path as NSString).appendingPathComponent(directoryName)
        try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    func markExecutable(_ filePath: String) {
        do {
            var attributes = try fileManager.attributesOfItem(atPath: filePath)
            
            let currentPermissions = attributes[.posixPermissions] as? UInt16 ?? 0
            let newPermissions = currentPermissions | UInt16(0o111)
            attributes[.posixPermissions] = NSNumber(value: newPermissions)
            try fileManager.setAttributes(attributes, ofItemAtPath: filePath)
            
        } catch {
            print("Error: \(error)")
        }
    }
}

extension UserDefaults {
    static var favorites: UserDefaults {
        return UserDefaults(suiteName: "com.whitetailani.Spartan.favorites") ?? UserDefaults.standard
    }
    static var settings: UserDefaults {
        return UserDefaults(suiteName: "com.whitetailani.Spartan.settings") ?? UserDefaults.standard
    }
    static var textedit: UserDefaults {
        return UserDefaults(suiteName: "com.whitetailani.Spartan.texteditor") ?? UserDefaults.standard
    }
}
