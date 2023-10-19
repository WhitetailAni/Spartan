//
//  ImageView.swift
//  Spartan
//
//  Created by RealKGB on 4/8/23.
//

import SwiftUI
import UIKit
import SVGWrapper

struct ImageView: View {
    @State var imagePath: String
    @State var imageName: String
    @State var isSVG: Bool
    
    @State private var imageToDisplay: UIImage?
    
    @State private var infoShow = false
    
    init(imagePath: String, imageName: String, isSVG: Bool) {
		_imagePath = State(initialValue: imagePath)
		_imageName = State(initialValue: imageName)
		_isSVG = State(initialValue: isSVG)
		
		if isSVG {
			do {
				let svgImage = try SVGDocument(fileURL: URL(fileURLWithPath: imagePath + imageName))
				let config = SVGDocument.ImageCreationConfiguration(scale: 1.0, orientation: .up)
				_imageToDisplay = State(initialValue: svgImage.uiImage(configuration: config))
			} catch {
				print("Could not init an svg from file")
			}
		} else {
			if let image = UIImage(contentsOfFile: imagePath + imageName) {
				_imageToDisplay = State(initialValue: image)
			}
		}
	}
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if imageToDisplay != nil {
                GeometryReader { geo in
					Image(uiImage: imageToDisplay!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width+50, height: geo.size.height+50)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                        .background(UIKitTapGesture(action: {
                            infoShow = true
                        }))
                }
            } else {
                Text(NSLocalizedString("IMAGE_ERROR", comment: "Honey begins when our valiant Pollen Jocks bring the nectar to the hive."))
            }
        }
        .sheet(isPresented: $infoShow) {
            let (width, height, size) = getImageInfo(filePath: imagePath + imageName) ?? (0, 0, 0)
            VStack{
                Text(imagePath + imageName)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .font(.system(size: 40))
                    .multilineTextAlignment(.center)
                Text(NSLocalizedString("DIMENSIONS", comment: "Our top-secret formula") + String(width) + "x" + String(height))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                Text(NSLocalizedString("INFO_SIZE", comment: "is automatically color-corrected, scent-adjusted and bubble-contoured") + String(size) + " " + NSLocalizedString("BYTES", comment: "into this soothing sweet syrup"))
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                Button(action: {
                    infoShow = false
                }) {
                    Text(NSLocalizedString("DISMISS", comment: "Honey!"))
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    func getImageInfo(filePath: String) -> (width: Int, height: Int, size: Int)? {
		guard let cgImageToRead = getCGImage(filePath: filePath) else {
			return nil
		}

        let fileSize = (try? FileManager.default.attributesOfItem(atPath: filePath)[.size] as? Int) ?? 0
        
		return (cgImageToRead.width, cgImageToRead.height, fileSize)
    }
    
    func getCGImage(filePath: String) -> CGImage? {
		if isSVG {
			do {
				let svg = try SVGDocument(fileURL: URL(fileURLWithPath: filePath))
				return svg.cgImage(withSize: svg.uiImage(configuration: SVGDocument.ImageCreationConfiguration(scale: 1.0, orientation: .up)).size)!
			} catch {
				return nil
			}
		} else {
			if let cgImageSource = CGImageSourceCreateWithURL(URL(fileURLWithPath: filePath) as CFURL, nil) {
				return CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil)
			}
		}
		return nil
	}
}
