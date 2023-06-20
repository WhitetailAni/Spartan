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
    
    @State var producedCUICatalog = CUICatalog()
    @State var producedRenditions: [Rendition] = []
    @State var itemLabelList: [String] = []
    
    let wrapper = AssetCatalogWrapper()

    var body: some View {
        Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 60)
            }
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
        
        List(producedRenditions, id: \.self) { rendition in
            Button(action: {
                print("lol")
            }) {
                if(rendition._getImage() != nil) {
                    Image(uiImage: UIImage(cgImage: rendition._getImage()!))
                }
                
                Text(rendition.name)
            }
        }
        
        .onAppear {
            fileURL = URL(fileURLWithPath: filePath + fileName)
            do {
                try producedCUICatalog = wrapper.renditions(forCarArchive: fileURL).0
                let producedRenditionCollection = try wrapper.renditions(forCarArchive: fileURL).1
                for (_, renditions) in producedRenditionCollection {
                    producedRenditions.append(contentsOf: renditions)
                }
            } catch {
                itemLabelList = ["An error occurred while trying to read the file", "It could not exist, be invalid, or be corrupted.", "Ensure you opened the right file, and then try again."]
            }
        }
    }
}
