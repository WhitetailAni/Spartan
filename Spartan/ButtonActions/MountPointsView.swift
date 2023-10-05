//
//  MountPointsView.swift
//  Spartan
//
//  Created by RealKGB on 4/27/23.
//

import SwiftUI
import Foundation
import DiskImagesWrapper

struct MountPointsView: View {
    @Binding var directory: String
    @Binding var isPresented: Bool
    
    @State private var mountDevices: [Mount] = []
    let null32: Int32 = 0
    
    @State var error = false
    
    var body: some View {
        Text(NSLocalizedString("MOUNT_TITLE", comment: "- I don't know."))
            .bold()
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
            .font(.system(size: 40))
            
        List(mountDevices.indices, id: \.self) { index in
			HStack {
				if mountDevices[index].device != "" {
					Button(action: {
						unmount(mountDevices[index].mountPoint, 0)
						do {
							try DiskImages.shared.detachDevice(at: URL(fileURLWithPath: mountDevices[index].device))
						} catch {
							
						}
					}) {
						Image(systemName: "eject")
					}
					.buttonStyle(.plain)
					.alert(isPresented: $error) {
						Alert(
							title: Text(LocalizedString("ERROR")),
							message: Text(LocalizedString("DMG_FAILTOEJECT")),
							dismissButton: .default(Text(LocalizedString("DISMISS")))
						)
					}
				}
				Button(action: {
					directory = mountDevices[index].mountPoint + "/"
					isPresented = false
				}) {
					Text("\(mountDevices[index].device) \(NSLocalizedString("MOUNT_DESC", comment: "Their day's not planned.")) \(mountDevices[index].mountPoint)")
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 40)
						}
				}
				.buttonStyle(.plain)
            }
        }
    }
    
    func getMountedFileSystems() -> [Mount] {
        var mounts = [Mount]()
        var mntbuf: UnsafeMutablePointer<statfs>? = nil
        let count = getmntinfo(&mntbuf, 0)
        
        if count > 0 {
            for i in 0..<count {
                var mnt = mntbuf![Int(i)]
                let device = withUnsafePointer(to: &mnt.f_mntfromname) {
                    $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) {
                        String(cString: $0)
                    }
                }
                let mountPoint = withUnsafePointer(to: &mnt.f_mntonname) {
                    $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXPATHLEN)) {
                        String(cString: $0)
                    }
                }
                let help = #"\"#
                let mount = Mount(device: String("\(device)\(help)"), mountPoint: mountPoint)
                mounts.append(mount)
            }
        }
        return mounts
    }
}

struct Mount {
    var device: String
    var mountPoint: String
}
