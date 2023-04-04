//
//  ContentView.swift
//  Spartan
//
//  Created by RealKGB on 4/3/23.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @State var directory: String
    @State private var workingDir: String = "/"
    @State private var files: [String] = []
    @State private var selectedFile: FileInfo?
    @State private var textSuccess = false
    @State var i = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Input directory", text: $directory)
                    Button(action: {
                        updateFiles()
                        i += 1
                        print(i)
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    if(i == 4){
                        //summon credits
                    }
                }
                List {
                    Button(action: {
                        goBack()
                    }) {
                        HStack {
                            Image(systemName: "arrowshape.turn.up.backward")
                            Text("..")
                        }
                    }
                    ForEach(files, id: \.self) { file in
                        Button(action: {
                            if file.hasSuffix("/") {
                                directory += file
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
                    if(textSuccess){
                        Text("**Text Editor**")
                    }
                    Text(readFile(path: directory + file.name))
                }
                .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(rawValue: "MenuPressedNotification"))) { _ in
                    goBack()
                }
            }
        }
    }

    func updateFiles() {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directory)
            files = contents.map { file in
                let filePath = "/" + directory + "/" + file
                var isDirectory: ObjCBool = false
                FileManager.default.fileExists(atPath: filePath, isDirectory: &isDirectory)
                return isDirectory.boolValue ? "\(file)/" : file
            }
        } catch {
            print("something broke: \(error.localizedDescription)")
        }
    }
    
    func readFile(path: String) -> String {
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            textSuccess = true
            return content
        } catch {
            print("something broke: \(error.localizedDescription)")
            return "\(error.localizedDescription)"
        }
    }
    
    func goBack() {
        guard directory != "/" else { return }
        var components = directory.split(separator: "/")
    
        if components.count > 1 {
            components.removeLast()
            directory = "/" + components.joined(separator: "/") + "/"
        } else if components.count == 1 {
            directory = "/"
        }
            updateFiles()
    }
}

struct creditsView: View {
    var body: some View {
        //will put something here eventually
    }
}

struct FileInfo: Identifiable {
    let name: String
    let id: UUID
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(directory: "/")
    }
}
