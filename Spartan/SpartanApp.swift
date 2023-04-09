//
//  SpartanApp.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
import AVKit
import MobileCoreServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? ["No favorites"])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/var/mobile/Media/.Trash/"])
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let contentView = ContentView(directory: "/var/containers/Bundle/Application/18D0B73C-CE75-4E8B-8EF0-164543775BCD/trillstore.app/")
        //let contentView = ContentView(directory: "/var/mobile/")
        let hostingController = UIHostingController(rootView: contentView)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        
        createTrash()
        
        @State var favoritesDisplayName: [String] = ["Trash"]
        @State var favoritesFilePath: [String] = ["/var/mobile/Media/.Trash/"]
        UserDefaults.favorites.set(favoritesDisplayName, forKey: "favoritesDisplayName")
        UserDefaults.favorites.set(favoritesFilePath, forKey: "favoritesFilePath")
        
        return true
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
        let fileManager = FileManager.default
        let directoryPath = (path as NSString).appendingPathComponent(directoryName)
        try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
    }
}

extension UserDefaults {
    static var favorites: UserDefaults {
        return UserDefaults(suiteName: "com.whitetailani.Spartan.favorites") ?? UserDefaults.standard
    }
}
