//
//  SpartanApp.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
import AVKit
//import GCDWebServer
@_exported import LaunchServicesBridge

@main
class AppDelegate: UIResponder, UIApplicationDelegate { /*ordinarily this would be an incredibly simple function:

@main
struct SpartanApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
 
 but that would require having a tvOS 14.0+ application. tvOS 13 doesn't do that. you have to use the old UIKit method with some swiftUI hacked in it.
 it works for me though, since I have to do some setup stuff here anyway.
 
 */
    var window: UIWindow?
    @State var directoryToLoad: String = ""
    
    @State var favoritesDisplayName: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesDisplayName") ?? [NSLocalizedString("NOFAVORITES", comment: "The Bee Movie Script Will Be Located In NSLocalizedString Comments")])
    @State var favoritesFilePath: [String] = (UserDefaults.favorites.stringArray(forKey: "favoritesFilePath") ?? ["/private/var/mobile/Media/.Trash/"])
    
    @State private var buttonWidth: CGFloat = 0
    @State private var buttonHeight: CGFloat = 0
    
    @State var player = AVPlayer()
	//let server = GCDWebUploader(uploadDirectory: [URL(fileURLWithPath: "/private/var/mobile/Documents/")])
	//someday... over the rainbow...
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if UserDefaults.settings.string(forKey: "tvapothecary") == nil {
            UserDefaults.settings.set(randomString(length: 24), forKey: "tvapothecary")
        }
        
        if !(UserDefaults.settings.bool(forKey: "haveLaunchedBefore")) {
            UserDefaults.settings.set(25, forKey: "logWindowFontSize")
            UserDefaults.settings.set(true, forKey: "autoComplete")
            UserDefaults.settings.set(true, forKey: "haveLaunchedBefore")
            UserDefaults.settings.set("MM-dd-yyyy HH:mm", forKey: "dateFormat")
            
            UserDefaults.settings.set(true, forKey: "haveLaunchedBefore")
            UserDefaults.settings.synchronize()
        }
        
        if #available(tvOS 17.0, *) {
            sw_vers = .dawn
        } else if #available(tvOS 16.0, *) {
            sw_vers = .sydney
        } else if #available(tvOS 15.0, *) {
            sw_vers = .satellite
        } else if #available(tvOS 14.0, *) {
            sw_vers = .archer
        }
        
        if(!(Spartan.fileManager.fileExists(atPath: "/private/var/mobile/Media/.Trash"))){
            RootHelperActs.mkdir("/private/var/mobile/Media/.Trash")
        } else {
            print("Trash already exists")
        }
        
		if(Spartan.fileManager.isReadableFile(atPath: "/private/var/mobile/")){ //shows app data directory if sandbox exists
            //displayView(pathToLoad: "/private/var/mobile/Documents/")
            //displayView(pathToLoad: Bundle.main.bundlePath)
            //displayView(pathToLoad: "/private/var/containers/Bundle/Application/2A65A51A-4061-4143-B622-FA0E57C0C3EE/trillstore.app/")
            displayView(pathToLoad: "/private/var/mobile/")
        } else {
            displayView(pathToLoad: "/Developer/")
        }
        
        return true
    }
    
    func displayView(pathToLoad: String) {
        let isRootless = {
			if(Spartan.fileManager.fileExists(atPath: "/private/var/jb/")) { //rootless tvos :woeis:
                return true
            }
            return false
        }()
        let hostingController = UIHostingController(rootView: ContentView(directory: pathToLoad, isRootless: isRootless, scaleFactor: UIScreen.main.nativeBounds.height/1080, globalAVPlayer: $player /*, webServer: $server*/))
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = hostingController
            window?.makeKeyAndVisible()
    }
}

extension UserDefaults {
    static var favorites: UserDefaults {
        return UserDefaults(suiteName: "com.whitetailani.Spartan.favorites") ?? UserDefaults.standard
    }
    static var settings: UserDefaults {
        return UserDefaults(suiteName: "com.whitetailani.Spartan.settings") ?? UserDefaults.standard
    }
    // so it turns out the text editor did NOT need its own userdefaults. i never used it. no idea why i created it.
}
