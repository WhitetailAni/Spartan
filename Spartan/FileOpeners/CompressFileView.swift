//
//  ZipFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/15/23.
//

import SwiftUI
import Zip

let compTypes = ["zip", "gzip", "bzip2", "xz", "lzma", "lz4", "zstd", "tar"]
let tarCompTypes = ["gzip", "bzip2", "xz", "lzma"]

struct CompressFileView: View {
    @Binding var isPresented: Bool
    @State var directory: String
    @State var fileNames: [String] //files to be archived
    @State var multipleFiles: Bool
    
    @State private var selectedCompType: CompressionType = .zip
    @State private var selectedTarCompType: TarCompressionType = .none
    @State private var compPassword: String = ""
    
    @State private var destPath = ""
    
    var body: some View {
        VStack {
            Text(localizedString: "COMP_TITLE")
                .font(.system(size: 60))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 25)
                }
            
            Picker(LocalizedString("COMP_TYPE"), selection: $selectedCompType) {
                Text("zip").tag(CompressionType.zip)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                    }
                Text("gzip").tag(CompressionType.gz).disabled(multipleFiles)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                    }
                Text("bzip2").tag(CompressionType.bz2).disabled(multipleFiles)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                    }
                Text("xz").tag(CompressionType.xz).disabled(multipleFiles)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                    }
                Text("lzma").tag(CompressionType.lzma).disabled(multipleFiles)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                    }
                Text("lz4").tag(CompressionType.lz4).disabled(multipleFiles)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                    }
                Text("zstd").tag(CompressionType.zstd)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                    }
                Text("tar").tag(CompressionType.tar)
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                    }
            }
            
            if selectedCompType == .tar {
                Picker(LocalizedString("COMP_TARTYPE"), selection: $selectedTarCompType) {
                    Text("none").tag(TarCompressionType.none)
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                        }
                    Text("gzip").tag(TarCompressionType.gz)
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                        }
                    Text("bzip2").tag(TarCompressionType.bz2)
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                        }
                    Text("xz").tag(TarCompressionType.xz)
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                        }
                    Text("lzma").tag(TarCompressionType.lzma)
                        .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                            view.scaledFont(name: "BotW Sheikah Regular", size: 35)
                        }
                }
            }
            
            TextField("COMP_DESTNAME", text: $destPath)
            
            Button(action: {
                if multipleFiles {
                    compressFiles(listOfFiles: fileNames, destination: directory + destPath, compType: selectedCompType, tarCompType: selectedTarCompType)
                } else {
                    compressFile(pathToFile: fileNames[0], destination: directory + destPath, compType: selectedCompType, tarCompType: selectedTarCompType)
                }
            }) {
                Text(localizedString: "CONFIRM")
            }
        }
    }
    
    func compressFile(pathToFile: String, destination: String, compType: CompressionType, tarCompType: TarCompressionType) {
        switch compType {
        case .zip:
            spawn(command: "/usr/bin/zip", args: [destination, pathToFile], root: true)
        case .gz:
            spawn(command: "/usr/bin/gzip", args: ["-k", pathToFile], root: true)
            RootHelperActs.mv((pathToFile + ".gz"), destination)
        case .bz2:
            spawn(command: "/usr/bin/bzip2", args: ["-k", "-z", pathToFile, destination], root: true)
            RootHelperActs.mv((pathToFile + ".bz2"), destination)
        case .xz:
            spawn(command: "/usr/bin/xz", args: ["-k", "-z", pathToFile], root: true)
            RootHelperActs.mv((pathToFile + ".xz"), destination)
        case .zstd:
            spawn(command: "/usr/bin/zstd", args: ["-k", "-z", pathToFile, "-o", destination], root: true)
        case .lzma:
            spawn(command: "/usr/bin/lzma", args: ["-k", "-z", pathToFile], root: true)
            RootHelperActs.mv((pathToFile + ".lzma"), destination)
        case .lz4:
            spawn(command: "/usr/bin/lz4", args: [pathToFile, destination], root: true)
        case .tar:
            switch tarCompType {
            case .none:
                spawn(command: "/usr/bin/tar", args: ["-cvf", destination, pathToFile], root: true)
            case .gz:
                spawn(command: "/usr/bin/tar", args: ["-czvf", destination, pathToFile], root: true)
            case .bz2:
                spawn(command: "/usr/bin/tar", args: ["-cjvf", destination, pathToFile], root: true)
            case .xz:
                spawn(command: "/usr/bin/tar", args: ["-cJvf", destination, pathToFile], root: true)
            case .lzma:
                spawn(command: "/usr/bin/tar", args: ["-c", "--lzma", "-vf", destination, pathToFile], root: true)
            }
        }
    }
    
    func compressFiles(listOfFiles: [String], destination: String, compType: CompressionType, tarCompType: TarCompressionType = .none) {
        var stringList = ""
        for file in listOfFiles {
            stringList += "\(file) "
        }
        
        switch compType {
        case .zip:
            spawn(command: "/usr/bin/zip", args: ["-r", destination, stringList], root: true)
        case .gz:
            return
        case .bz2:
            return
        case .xz:
            return
        case .zstd:
            spawn(command: "/usr/bin/zstd", args: ["-z", "-r", stringList, destination], root: true)
        case .lzma:
            return
        case .lz4:
            return
        case .tar:
            switch tarCompType {
            case .none:
                spawn(command: "/usr/bin/tar", args: ["-cvf", destination, stringList], root: true)
            case .gz:
                spawn(command: "/usr/bin/tar", args: ["-czvf", destination, stringList], root: true)
            case .bz2:
                spawn(command: "/usr/bin/tar", args: ["-cjvf", destination, stringList], root: true)
            case .xz:
                spawn(command: "/usr/bin/tar", args: ["-cJvf", destination, stringList], root: true)
            case .lzma:
                spawn(command: "/usr/bin/tar", args: ["-c", "--lzma", "-vf", destination, stringList], root: true)
            }
        }
    }
}

struct UncompressFileView: View {
    @State private var extractFilePath: String = ""
    
    var body: some View {
        VStack {
            Text(localizedString: "UNCOMP_TITLE")
                .font(.system(size: 60))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 60)
                }
            TextField("UNCOMP_DIR", text: $extractFilePath)
            
            Button(action: {
                
            }) {
                Text("CONFIRM")
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
        }
    }
    
    func uncompressFile(pathToFile: String, compType: CompressionType, tarCompType: TarCompressionType = .none) {
        switch compType {
        case .zip:
            spawn(command: "/usr/bin/unzip", args: ["-o", pathToFile], root: true)
        case .gz:
            spawn(command: "/usr/bin/gunzip", args: ["-f", "-k", pathToFile], root: true)
        case .bz2:
            spawn(command: "/usr/bin/bunzip2", args: ["-k", "-f", pathToFile], root: true)
        case .xz:
            spawn(command: "/usr/bin/xz", args: ["-k", "-d", "-f", pathToFile], root: true)
        case .zstd:
            spawn(command: "/usr/bin/zstd", args: ["-k", "-d", pathToFile], root: true)
        case .lzma:
            spawn(command: "/usr/bin/lzma", args: ["-k", "-d", pathToFile], root: true)
        case .lz4:
            spawn(command: "/usr/bin/lz4", args: ["-d", pathToFile], root: true)
        case .tar:
            switch tarCompType {
            case .none:
                spawn(command: "/usr/bin/tar", args: ["-xvf", pathToFile], root: true)
            case .gz:
                spawn(command: "/usr/bin/tar", args: ["-xzvf", pathToFile], root: true)
            case .bz2:
                spawn(command: "/usr/bin/tar", args: ["-xjvf", pathToFile], root: true)
            case .xz:
                spawn(command: "/usr/bin/tar", args: ["-xJvf", pathToFile], root: true)
            case .lzma:
                spawn(command: "/usr/bin/tar", args: ["-x", "--lzma", "-vf", pathToFile], root: true)
            }
        }
    }
}

enum CompressionType {
    case zip
    case gz
    case bz2
    case xz
    case zstd
    case lzma
    case lz4
    case tar
    
    func stringRepresentation() -> String { //a better way to do this? definitely.
        switch self {
        case .zip:
            return ".zip"
        case .gz:
            return ".gz"
        case .bz2:
            return ".bz2"
        case .xz:
            return ".xz"
        case .zstd:
            return ".zst"
        case .lzma:
            return ".lzma"
        case .lz4:
            return ".lz4"
        case .tar:
            return ".tar"
        }
    }
}

enum TarCompressionType {
    case none
    case gz
    case bz2
    case xz
    case lzma
    
    func stringRepresentation() -> String { //do i care? no
        switch self {
        case .none:
            return ""
        case .gz:
            return ".gz"
        case .bz2:
            return ".bz2"
        case .xz:
            return ".xz"
        case .lzma:
            return ".lzma"
        }
    }
}
