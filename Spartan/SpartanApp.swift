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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let contentView = ContentView(directory: "/var/containers/Bundle/Application/7A5EBFBD-1D69-44E2-B1D5-484363F82032/trillstore.app/")
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
                print("Created trash directory")
                try createDirectoryAtPath(path: "/var/mobile/Media", directoryName: ".Trash")
            } catch {
                print("Failed to create trash")
            }
        }
    }
    
    func createDirectoryAtPath(path: String, directoryName: String) throws {
        let fileManager = FileManager.default
        let directoryPath = (path as NSString).appendingPathComponent(directoryName)
        try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
    }
}
