//
//  PlistBootstrapView.swift
//  Spartan
//
//  Created by RealKGB on 8/23/23.
//

import SwiftUI

struct PlistBootstrapView: View {
	@State var lmao: Double = 69
	
    var body: some View {
        UIKitProgressView(value: $lmao, total: 100)
			.onAppear {
				
			}
    }
}
