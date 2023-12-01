//
//  Compression.swift
//  Spartan
//
//  Created by WhitetailAni on 12/1/23.
//

import Foundation

enum CompressionType {
    case zip
    case gz
    case bz2
    case xz
    case zstd
    case lzma
    case lz4
    case tar
    case unknown
    
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
        case .unknown:
            return ""
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
    
    init(type: CompressionType)  {
        switch type.stringRepresentation() {
        case ".gz":
            self = .gz
        case ".bz2":
            self = .bz2
        case ".xz":
            self = .xz
        case ".lzma":
            self = .lzma
        default:
            self = .none
        }
    }
}

class Compression {
    class func compressFile(pathToFile: String, destination: String, compType: CompressionType, tarCompType: TarCompressionType) {
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
        case .unknown:
            print("no")
        }
    }
    
    class func compressFiles(listOfFiles: [String], destination: String, compType: CompressionType, tarCompType: TarCompressionType = .none) {
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
        case .unknown:
            print("no")
        }
    }
    
    class func uncompressFile(pathToFile: String, compType: CompressionType, tarCompType: TarCompressionType) {
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
        case .unknown:
            print("")
        }
    }
    
    class func archiveType(filePath: String) -> (CompressionType, TarCompressionType) {
        guard let data = fileManager.contents(atPath: filePath) else {
            return (.unknown, .none)
        }
        let zip = Data(fromHexEncodedString: "504B")
        let gzip = Data(fromHexEncodedString: "1F8B0808")
        let xz = Data(fromHexEncodedString: "FD377A58")
        let bzip2 = Data(fromHexEncodedString: "425A6839")
        let lzma = Data(fromHexEncodedString: "5D000080")
        let lz4 = Data(fromHexEncodedString: "04224D18")
        let zstd = Data(fromHexEncodedString: "28B52FFD")
        let targz = Data(fromHexEncodedString: "1F8B0800")
        
        var comp: CompressionType = .unknown
        var tarComp: TarCompressionType = .none
        
        if data.count > 8 {
            let header = data.subdata(in: 0..<8)
            if header.subdata(in: 0..<4) == zip {
                comp = .zip
            } else if header == targz {
                comp = .tar
                tarComp = .gz
            } else {
                switch header {
                case gzip:
                    comp = .gz
                case xz:
                    comp = .xz
                case bzip2:
                    comp = .bz2
                case lzma:
                    comp = .lzma
                case lz4:
                    comp = .lz4
                case zstd:
                    comp = .zstd
                default:
                    nop()
                }
                if FileInfo.isTar(filePath: filePath) {
                    tarComp = TarCompressionType(type: comp)
                    comp = .tar
                }
            }
        }
        return (comp, tarComp)
    }
}
