//
//  SpartanApp.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
import AVKit
import MobileCoreServices
import Foundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    @State var directoryToLoad: String = ""
    
    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? ["No favorites"])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/var/mobile/Media/.Trash/"])
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        UserDefaults.settings.set(true, forKey: "autoComplete")
        
        if(FileManager.default.isReadableFile(atPath: "/var/mobile/")){ //shows app data directory if sandbox exists
            displayView(pathToLoad: "/var/mobile/")
            //displayView(pathToLoad:  "/var/containers/Bundle/Application/2A65A51A-4061-4143-B622-FA0E57C0C3EE/trillstore.app/")
            //displayView(pathToLoad: "/etc/")
        } else {
            displayView(pathToLoad: getDataDirectory())
        }
        
        createTrash()
        
        return true
    }
    
    func displayView(pathToLoad: String) {
        let hostingController = UIHostingController(rootView: ContentView(directory: pathToLoad))
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
