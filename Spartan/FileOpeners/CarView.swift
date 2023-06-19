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
    @State var producedRendition = RenditionCollection()
    @State var itemLabelList: [String] = []
    
    let wrapper = AssetCatalogWrapper()

    var body: some View {
        Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 60)
            }
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
        /*List(itemLabelList, id: \.self) { passenger in
            Text(passenger)
        }*/
        .onAppear {
            fileURL = URL(fileURLWithPath: filePath + fileName)
            print(fileName)
            print(filePath)
            print(fileURL)
            do {
                try producedCUICatalog = wrapper.renditions(forCarArchive: fileURL).0
                try producedRendition = wrapper.renditions(forCarArchive: fileURL).1
            } catch {
                itemLabelList = ["An error occurred while trying to read the file", "It could not exist, be invalid, or be corrupted.", "Ensure you opened the right file, and then try again."]
            }
            print(producedCUICatalog)
            print(producedRendition)
        }
    }
}
