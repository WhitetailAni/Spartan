//
//  DpkgView.swift
//  Spartan
//
//  Created by RealKGB on 5/12/23.
//

import SwiftUI

struct DpkgView: View {
    
    @Binding var debPath: String
    @Binding var debName: String

    var body: some View {
        if !(FileManager.default.fileExists(atPath: "/usr/bin/dpkg") || FileManager.default.fileExists(atPath: "/var/jb/usr/bin/dpkg")) {
            Text("You need to be jailbroken to install debs.")
                .font(.system(size: 60))
        } else {
            Text("A")
        }
    }
}
