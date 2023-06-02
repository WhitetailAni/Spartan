//
//  CarView.swift
//  Spartan
//
//  Created by RealKGB on 5/30/23.
//

import SwiftUI

struct CarView: View {
    @Binding var filePath: String
    @Binding var fileName: String
    

    var body: some View {
        Text(UserDefaults.settings.bool(forKey: "verboseTimestamps") ? filePath + fileName : fileName)
            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                view.scaledFont(name: "BotW Sheikah Regular", size: 60)
            }
            .font(.system(size: 60))
            .multilineTextAlignment(.center)
        List(trunkOpener(), id: \.self) { assetName in
            HStack {
                boxOpener(named: assetName)
                Text(assetName)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        }
    }
    
    @ViewBuilder
    func boxOpener(named imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
            .padding()
    }
    
    func trunkOpener() -> [String] {
        let assetURL = URL(fileURLWithPath: filePath + fileName)
        
        do {
            let assetData = try Data(contentsOf: assetURL)
            let assetCatalog = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: assetData)
            
            return assetCatalog?.compactMap { asset in
                guard let imageName = (asset as? NSDictionary)?["name"] as? String else { return nil }
                return imageName
            } ?? []
        } catch {
            print("Error: \(error.localizedDescription)")
            return []
        }
    }
}
