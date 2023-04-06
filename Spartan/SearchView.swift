//
//  SearchView.swift
//  Spartan
//
//  Created by RealKGB on 4/6/23.
//

import SwiftUI

struct SearchView: View {

    @State var searchTerm: String = ""
    
    var body: some View {
        TextField("Enter file or directory name to search for", text: $searchTerm)
    }
}

