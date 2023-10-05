//
//  FontView.swift
//  Spartan
//
//  Created by RealKGB on 6/19/23.
//

import SwiftUI
import CoreGraphics

struct FontView: View {
    @Binding var filePath: String
    @Binding var fileName: String

    var body: some View {
        Text(UserDefaults.settings.bool(forKey: "descriptiveTitles") ? filePath + fileName : fileName)
            .font(Font.system(size: 40))
            .multilineTextAlignment(.center)
            
        Spacer()
        let font = loadFont()
        if font != nil {
            Text(demoPrep(font: loadFont()!))
                .font(Font(cgFont: loadFont()!, size: 40))
        } else {
            Text("The font file is not valid or not supported. Please make sure the file is not corrupted and is a supported font file, and then try again.")
        }
        
        Spacer()
    }
    
    func loadFont() -> CGFont? {
        let font = URL(fileURLWithPath: filePath + fileName)
        print(filePath + fileName)
        
        if let dataProvider = CGDataProvider(url: font as CFURL) {
            return CGFont(dataProvider)
        }
        return nil
    }
    
    func demoPrep(font: CGFont) -> String {
        let glyphCount = font.numberOfGlyphs
        var supportedCharacters: [Character] = []

        for glyph in 0..<glyphCount {
            let glyphName = font.name(for: CGGlyph(glyph))
            if let glyphName = glyphName as String?,
                let unicode = UnicodeScalar(glyphName) {
                let character = Character(unicode)
                supportedCharacters.append(character)
            }
        }
        
        return String(supportedCharacters)
    }
}
