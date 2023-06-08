//
//  SpartanApp.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    @State var directoryToLoad: String = ""
    
    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? [NSLocalizedString("NOFAVORITES", comment: "The Bee Movie Script Will Be Located In NSLocalizedString Comments")])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/var/mobile/Media/.Trash/"])
    
    @State private var buttonWidth: CGFloat = 0
    @State private var buttonHeight: CGFloat = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        if(!UserDefaults.settings.bool(forKey: "haveLaunchedBefore")) {
            UserDefaults.settings.set(25, forKey: "logWindowFontSize")
            UserDefaults.settings.set(true, forKey: "autoComplete")
            UserDefaults.settings.set(true, forKey: "haveLaunchedBefore")
            UserDefaults.settings.synchronize()
        }
        
        if(FileManager.default.isReadableFile(atPath: "/var/mobile/")){ //shows app data directory if sandbox exists
            displayView(pathToLoad: "/private/var/mobile/")
            //displayView(pathToLoad:  "/private/var/containers/Bundle/Application/2A65A51A-4061-4143-B622-FA0E57C0C3EE/trillstore.app/")
        } else {
            displayView(pathToLoad: getDataDirectory())
            //displayView(pathToLoad: "/Users/realkgb/Documents/") //used in case of simulator
        }
        
        createTrash()
        
        return true
    }
    
    func displayView(pathToLoad: String) {
        var isRootless = false
        if(FileManager.default.fileExists(atPath: "/var/jb/")) {
            isRootless = true
        }
        let hostingController = UIHostingController(rootView: ContentView(directory: pathToLoad, isRootless: isRootless))
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = hostingController
            window?.makeKeyAndVisible()
    }
    
    func createTrash() {
        if(!(FileManager.default.fileExists(atPath: "/var/mobile/Media/.Trash"))){
            do {
                try createDirectoryAtPath(path: "/var/mobile/Media", directoryName: ".Trash")
                print("Created trash directory")
            } catch {
                print("Failed to create trash")
            }
        } else {
            print("Trash already exists")
        }
    }
    
    func createDirectoryAtPath(path: String, directoryName: String) throws {
        guard FileManager.default.fileExists(atPath: "/var/mobile/Media/.Trash/") else {
            print("Trash already exists")
            return
        }
        let directoryPath = (path as NSString).appendingPathComponent(directoryName)
        try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    func getDataDirectory() -> String {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let appDataDirectory = urls.first else {
            return "Data directory not found"
        }

        var path = appDataDirectory.path.split(separator: "/")
        path.removeLast()
        return "/" + path.joined(separator: "/") + "/"
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
