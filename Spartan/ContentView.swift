//
//  ContentView.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI

struct ContentView: View {
    @State private var directory: String = "/"
    @State private var files: [String] = []
    @State private var selectedFile: FileInfo?
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("input directory", text: $directory)
                    Button(action: updateFiles) {
                        Text("refresh")
                    }
                }
                List {
                    ForEach(files, id: \.self) { file in
                        Button(action: {
                            if file.hasSuffix("/") {
                                let tempadd = "/" + file
                                directory += tempadd
                                selectedFile = nil
                                updateFiles()
                            } else {
                                selectedFile = FileInfo(name: file, id: UUID())
                            }
                        }) {
                            HStack {
                                if file.hasSuffix("/") {
                                    Image(systemName: "folder")
                                } else {
                                    Image(systemName: "doc")
                                }
                                Text(file)
                            }
                        }
                    }
                }
                .navigationBarHidden(true)
                .onAppear {
                    updateFiles()
                }
                .sheet(item: $selectedFile) { file in
                    Text("coming soon")
                    Text(readFile(path: directory + file.name))
                }
            }
        }
    }
    
    func updateFiles() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
            files = contents.map { $0 }
        } catch {
            print("something broke: \(error.localizedDescription)")
        }
    }
    
    func readFile(path: String) -> String {
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            return content
        } catch {
            print("something broke: \(error.localizedDescription)")
            return ""
        }
    }
}

struct FileInfo: Identifiable {
    let name: String
    let id: UUID
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
