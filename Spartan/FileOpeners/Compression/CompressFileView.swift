//
//  ZipFileView.swift
//  Spartan
//
//  Created by RealKGB on 4/15/23.
//

import SwiftUI
import Zip
import libarchiveBridge

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
    
    @State var tarCompShow = false
    
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
                Text("")
                    .onAppear {
                        withAnimation {
                            tarCompShow = true
                        }
                    }
            }
            
            if tarCompShow {
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
                    Compression.compressFiles(listOfFiles: fileNames, destination: directory + destPath, compType: selectedCompType, tarCompType: selectedTarCompType)
                } else {
                    Compression.compressFile(pathToFile: fileNames[0], destination: directory + destPath, compType: selectedCompType, tarCompType: selectedTarCompType)
                }
            }) {
                Text(localizedString: "CONFIRM")
            }
        }
    }
}

struct UncompressFileView: View {
    @State var filePath: String
    @State var fileName: String
    @State private var extractFilePath: String = ""
    
    var body: some View {
        VStack {
            Text(localizedString: "UNCOMP_TITLE")
                .font(.system(size: 60))
                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                    view.scaledFont(name: "BotW Sheikah Regular", size: 60)
                }
            TextField("UNCOMP_DIR", text: $extractFilePath)
                .onAppear {
                    extractFilePath = filePath
                }
            
            Button(action: {
                let compTypes = Compression.archiveType(filePath: filePath + fileName)
                Compression.uncompressFile(pathToFile: filePath + fileName, compType: compTypes.0, tarCompType: compTypes.1)
            }) {
                Text("CONFIRM")
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
            }
            .disabled(extractFilePath == "")
        }
    }
}
