//
//  HTMLView.swift
//  Spartan
//
//  Created by RealKGB on 10/25/23.
//

import SwiftUI

struct HTMLView: View {
	@State var filePath: String
	@State var fileName: String

    var body: some View {
		Text(UserDefaults.settings.bool(forKey: "descriptiveTitles") ? filePath + fileName : fileName)
				.font(Font.system(size: 40))
				.multilineTextAlignment(.center)
		
		GeometryReader { geometry in
			UIWebViewTV(bounds: CGRect(origin: geometry.frame(in: .global).origin, size: geometry.size), file: filePath + fileName)
		}
    }
}
