//
//  MountPointsView.swift
//  Spartan
//
//  Created by RealKGB on 4/27/23.
//

import SwiftUI
import Foundation

struct MountPointsView: View {
    @Binding var directory: String
    @Binding var isPresented: Bool
    
    @State private var mountDevices: [String] = []
    @State private var mountPoints: [String] = []
    
    let null32: Int32 = 0
    
    var body: some View {
        Text(NSLocalizedString("MOUNT_TITLE", comment: "- I don't know."))
            .font(.system(size: 40))
            .bold()
            .onAppear {
                for mount in getMountedFileSystems() {
                    mountDevices.append(mount.device)
                    mountPoints.append(mount.mountPoint)
                }
            }
            
        List(mountDevices.indices, id: \.self) { index in
            Button(action: {
                directory = mountPoints[index] + "/"
                isPresented = false
            }) {
                Text("\(mountDevices[index]) \(NSLocalizedString("MOUNT_DESC", comment: "Their day's not planned.")) \(mountPoints[index])")
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
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
                let mount = Mount(device: device, mountPoint: mountPoint)
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
