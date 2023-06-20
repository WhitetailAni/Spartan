//
//  CarView.swift
//  Spartan
//
//  Created by RealKGB on 5/30/23.
//

import SwiftUI
import UIKit
import AssetCatalogWrapper

struct CarView: View {
    @Binding var filePath: String
    @Binding var fileName: String
    @State var fileURL = URL(fileURLWithPath: "/")
    
    @State var producedRenditions: [Rendition] = []
    @State var errorMsg = ""
    
    let wrapper = AssetCatalogWrapper()

    var body: some View {
        Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 60)
            }
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
        
        List(producedRenditions, id: \.self) { rendition in
            if (errorMsg != "") {
                Text(errorMsg)
            }
            Button(action: {
                print("lol")
            }) {
                /*if(rendition.name.prefix(4) != "ZZZZ" || rendition.name == "App Icon") {
                    switch RenditionType(namedLookup: rendition.namedLookup) {
                    case .image:
                        Text("image")
                    case .icon:
                        Text("icon")
                    case .imageSet:
                        Text("image set")
                    case .multiSizeImageSet:
                        Text("multisize image set")
                    case .pdf:
                        Text("pdf")
                    case .color:
                        Text("color")
                    case .svg:
                        Text("svg")
                    case .rawData:
                        Text("data")
                    case .unknown:
                        Text("The asset type could not be determined.")
                    }
                }*/
                VStack(alignment: .leading) {
                    Text(rendition.name)
                    switch rendition.representation {
                    case .image:
                        Text("image")
                    case .color:
                        Text("color")
                    default:
                        Text("no clue")
                    }
                }
            }
        }
        
        .onAppear {
            fileURL = URL(fileURLWithPath: filePath + fileName)
            do {
                let producedRenditionCollection = try wrapper.renditions(forCarArchive: fileURL).1
                for (_, renditions) in producedRenditionCollection {
                    producedRenditions.append(contentsOf: renditions)
                }
            } catch {
                errorMsg = error.localizedDescription
            }
        }
    }
}
