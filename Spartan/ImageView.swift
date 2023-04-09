//
//  ImageView.swift
//  Spartan
//
//  Created by RealKGB on 4/8/23.
//

import SwiftUI

import SwiftUI
import UIKit

struct ImageView: View {
    @Binding var imagePath: String
    
    @GestureState private var isFocused = false
    @State private var infoShow = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let image = UIImage(contentsOfFile: imagePath) {
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            } else {
                Text("Could not load image from file")
            }
        }
        .sheet(isPresented: $infoShow) {
            let (width, height, fileSize, encoder) = getImageInfo(from: imagePath) ?? (0, 0, 0, "?")
            VStack{
                Text(imagePath)
                    .font(.system(size: 40))
                    .bold()
                    .multilineTextAlignment(.center)
                Text("Dimensions: " + String(width) + "x" + String(height))
                Text("File size: " + String(fileSize) + " bytes")
                Text("Image encoding: " + encoder)
                Button(action: {
                    infoShow = false
                }) {
                    Text("Dismiss")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func getImageInfo(from filePath: String) -> (width: Int, height: Int, size: Int, encoding: String)? {
        guard let imageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: filePath) as CFURL, nil) else {
            return nil
        }

        let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, propertiesOptions) as? [CFString: Any] else {
            return nil
        }

        let fileSize = (try? FileManager.default.attributesOfItem(atPath: filePath)[.size] as? Int) ?? 0
        let width = properties[kCGImagePropertyPixelWidth] as? Int ?? 0
        let height = properties[kCGImagePropertyPixelHeight] as? Int ?? 0
        let encoding = properties[kCGImagePropertyColorModel] as? String ?? "Unknown"

        return (width, height, fileSize, encoding)
    }
}
