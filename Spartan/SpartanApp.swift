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
    
    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? ["No favorites"])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/var/mobile/Media/.Trash/"])
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let contentView = ContentView(directory: "/var/mobile/")
        //let contentView = ContentView(directory: "/var/containers/Bundle/Application/2A65A51A-4061-4143-B622-FA0E57C0C3EE/trillstore.app/")
        let hostingController = UIHostingController(rootView: contentView)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = hostingController
        window?.makeKeyAndVisible()
        
        createTrash()
        
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
        guard FileManager.default.fileExists(atPath: "/var/mobile/Media/.Trash/") else {
            print("Trash already exists")
            return
        }
        let directoryPath = (path as NSString).appendingPathComponent(directoryName)
        try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
    }
}

extension UserDefaults {
    static var favorites: UserDefaults {
        return UserDefaults(suiteName: "com.whitetailani.Spartan.favorites") ?? UserDefaults.standard
    }
    static var settings: UserDefaults {
        return UserDefaults(suiteName: "com.whitetailani.Spartan.settings") ?? UserDefaults.standard
    }
}
