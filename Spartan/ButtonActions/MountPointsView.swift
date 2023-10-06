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
    
    @State private var noTouchyTheseMountPoints: [String] = ["/dev/disk0s1s1", "devfs", "/dev/disk0s1s5", "/private/preboot", "/private/var/hardware/FactoryData"]
    
    @State var error = false
    @State var errorDesc = ""
    
    var body: some View {
        Text(NSLocalizedString("MOUNT_TITLE", comment: "- I don't know."))
            .bold()
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
            }
            .font(.system(size: 40))
		
		List(mountDevices, id: \.self) { mount in
			HStack {
				if !(mount.device.hasPrefix("/dev/disk0") || mount.device.hasPrefix("devfs") || mount.device.hasPrefix("/dev/disk4") || mount.device.hasPrefix("/private/var/hardware/FactoryData/") || mount.device.hasPrefix("/private/preboot/")) {
					Button(action: {
						var result: Int32 = 0
						do {
							result = unmount(mount.device, MNT_FORCE)
							if result != 0 {
								throw "crap"
							}
						} catch {
							errorDesc = "Error code \(result) thrown by umount"
						}
						do {
							try DiskImages.shared.detachDevice(at: URL(fileURLWithPath: mount.device))
						} catch {
							errorDesc = LocalizedString("DMG_FAILTOEJECT")
						}
					}) {
						Image(systemName: "eject")
					}
					.buttonStyle(.bordered)
				}
				Button(action: {
					directory = mount.mountPoint + "/"
					isPresented = false
				}) {
					Text("\(mount.device) \(NSLocalizedString("MOUNT_DESC", comment: "Their day's not planned.")) \(mount.mountPoint)")
						.if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
							view.scaledFont(name: "BotW Sheikah Regular", size: 40)
						}
				}
				.buttonStyle(.bordered)
            }
        }
        .alert(isPresented: $error) {
			Alert(
				title: Text(LocalizedString("ERROR")),
				message: Text(errorDesc),
				dismissButton: .default(Text(LocalizedString("DISMISS")))
			)
		}
        .onAppear {
			mountDevices = getMountedFileSystems()
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
                let mount = Mount(device: device, mountPoint: mountPoint)
                mounts.append(mount)
            }
        }
        return mounts
    }
}

struct Mount: Hashable {
    var device: String
    var mountPoint: String
}
