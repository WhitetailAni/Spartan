//
//  CarView.swift
//  Spartan
//
//  Created by RealKGB on 5/30/23.
//

import SwiftUI
import AssetCatalogWrapper

struct CarView: View {
    @Binding var filePath: String
    @Binding var fileName: String
    
    @State var renditions2: [Rendition] = []
    @State var errorMsg = ""
    
    let wrapper = AssetCatalogWrapper()

    var body: some View {
        Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 60)
            }
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
        List(renditions2, id: \.self) { rendition in
            if (errorMsg != "") {
                Text(errorMsg)
            }
            Button(action: {
                print("lol")
            }) {
                Text(rendition.name)
            }
        }
        .onAppear {
            let fileURL = URL(fileURLWithPath: filePath + fileName)
            do {
                let renditionCollection = try wrapper.renditions(forCarArchive: fileURL).1
                for (_, renditions) in renditionCollection {
                    renditions2.append(contentsOf: renditions)
                }
            } catch { }
        }
    }
}
