//
//  Compression.swift
//  Spartan
//
//  Created by WhitetailAni on 12/1/23.
//

import Foundation
import libarchiveBridge
import Zip

//this file features claude 3 assistance with libarchive because C makes my head hurt

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
    
    init(type: TarCompressionType) {
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
            self = .unknown
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
    
    init(type: CompressionType) {
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

enum CompressionError: Error {
    case incorrectCompressionType
    case archiveCreationFailed
    
    case inputFileOpenFailed
    case outputFileOpenFailed
    
    case archiveReadHeaderFailed
    case archiveReadDataFailed
    
    case archiveWriteHeaderFailed
    case archiveWriteDataFailed
    
    case archiveFinishEntryFailed
    
    case archiveUnsupportedCompressionType
    
    func explanation() -> String {
        switch self {
        case .incorrectCompressionType:
            return LocalizedString("COMPERROR_INCORRECTCOMPRESSIONTYPE")
        case .archiveCreationFailed:
            return LocalizedString("COMPERROR_ARCHIVECREATIONFAILED")
        case .inputFileOpenFailed:
            return LocalizedString("COMPERROR_INPUTFILEOPENFAILED")
        case .outputFileOpenFailed:
            return LocalizedString("COMPERROR_OUTPUTFILEOPENFAILED")
        case .archiveReadHeaderFailed:
            return LocalizedString("COMPERROR_ARCHIVEREADHEADERFAILED")
        case .archiveReadDataFailed:
            return LocalizedString("COMPERROR_ARCHIVEREADDATAFAILED")
        case .archiveWriteHeaderFailed:
            return LocalizedString("COMPERROR_ARCHIVEWRITEHEADERFAILED")
        case .archiveWriteDataFailed:
            return LocalizedString("COMPERROR_ARCHIVEWRITEDATAFAILED")
        case .archiveFinishEntryFailed:
            return LocalizedString("COMPERROR_ARCHIVEFINISHENTRYFAILED")
        case .archiveUnsupportedCompressionType:
            return LocalizedString("COMPERROR_ARCHIVEUNSUPPORTEDCOMPRESSIONTYPE")
        }
    }
}

struct CompressionFileData {
    let file: UnsafeMutablePointer<FILE>
    let fileSize: Int
    var currentPosition: Int
    var buffer: UnsafeMutablePointer<UInt8>

    init(file: UnsafeMutablePointer<FILE>) {
        self.file = file
        var stat = stat()
        fstat(fileno(file), &stat)
        self.fileSize = Int(stat.st_size)
        self.currentPosition = 0
        self.buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 8192)
    }

    var bytesRead: Int {
        let bytesRead = fread(buffer, 1, 8192, file)
        return Int(bytesRead)
    }

    mutating func readNextChunk() {
        currentPosition += bytesRead
    }
}

class Compression {
    class func compressFile(filePath: String, directory: String, destination: String, compType: CompressionType, tarCompType: TarCompressionType) throws {
        switch compType {
        case .tar:
            do {
                try createTarC(filePaths: [filePath], destination: tempPath)
                if tarCompType != .none {
                    try compressFileC(filePath: tempPath, destination: destination, type: CompressionType(type: tarCompType))
                    RootHelperActs.rm(tempPath)
                } else {
                    RootHelperActs.mvtemp(destination)
                }
            }
        case .unknown:
            throw CompressionError.incorrectCompressionType
        default:
            do {
                try compressFileC(filePath: directory + filePath, destination: destination, type: compType)
            } catch {
                throw error
            }
        }
    }
    
    class func compressFiles(listOfFiles: [String], directory: String, destination: String, compType: CompressionType, tarCompType: TarCompressionType = .none) throws {
        var stringList = ""
        for file in listOfFiles {
            stringList += "\(file) "
        }
        
        print(listOfFiles)
        print(stringList)
        
        switch compType {
        case .zip:
            do {
                var urls: [URL] = []
                for file in listOfFiles {
                    urls.append(URL(fileURLWithPath: directory + file))
                }
                print(urls)
                try Zip.zipFiles(paths: urls, zipFilePath: URL(fileURLWithPath: destination), password: nil, progress: nil)
            } catch {
                throw CompressionError.archiveWriteHeaderFailed
            }
        case .zstd:
            var fullPaths: [String] = []
            for file in listOfFiles {
                fullPaths.append(directory + file)
            }
            do {
                try compressZstdC(filePaths: fullPaths, destination: destination)
            } catch {
                throw error
            }
        case .tar:
            var fullPaths: [String] = []
            for file in listOfFiles {
                fullPaths.append(directory + file)
            }
            do {
                try createTarC(filePaths: fullPaths, destination: tempPath)
                if tarCompType != .none {
                    try compressFileC(filePath: tempPath, destination: destination, type: CompressionType(type: tarCompType))
                    RootHelperActs.rm(tempPath)
                } else {
                    RootHelperActs.mvtemp(destination)
                }
            } catch {
                throw error
            }
        default:
            throw CompressionError.incorrectCompressionType
        }
    }
    
    class func uncompressFile(filePath: String, destination: String, compType: CompressionType) throws {
        switch compType {
        case .zip:
            do {
                try Zip.unzipFile(URL(fileURLWithPath: filePath), destination: URL(fileURLWithPath:destination), overwrite: true, password: nil)
            } catch {
                throw CompressionError.archiveReadDataFailed
            }
        case .zstd:
            do {
                try decompressZstdC(filePath: filePath, destination: destination)
            } catch {
                throw error
            }
        case .unknown:
            throw CompressionError.incorrectCompressionType
        default:
            do {
                try decompressFileC(filePath: filePath, destination: destination)
            } catch {
                throw error
            }
        }
    }
    
    class func archiveType(filePath: String) -> CompressionType {
        guard let data = fileManager.contents(atPath: filePath) else {
            print("epoch fail")
            return .unknown
        }
        let zip = Data(fromHexEncodedString: "504B")
        let gzip = Data(fromHexEncodedString: "1F8B0808")
        let xz = Data(fromHexEncodedString: "FD377A58")
        let bzip2 = Data(fromHexEncodedString: "425A6839")
        let lzma = Data(fromHexEncodedString: "5D000080")
        let lz4 = Data(fromHexEncodedString: "04224D18")
        let zstd = Data(fromHexEncodedString: "28B52FFD")
        
        var comp: CompressionType = .unknown
        
        if data.count > 4 {
            let header = data.subdata(in: 0..<4)
            for byte in header {
                print(String(format: "%02X", byte), terminator: "")
            }
            if header.subdata(in: 0..<2) == zip {
                comp = .zip
            } else if FileInfo.isTar(filePath: filePath) {
                comp = .tar
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
            }
        }
        print(comp.stringRepresentation())
        return comp
    }
    
    private class func createTarC(filePaths: [String], destination: String) throws {
        let archiveWriter = archive_write_new()
        archive_write_set_format_pax_restricted(archiveWriter)

        let archiveURL = URL(fileURLWithPath: destination)
        guard archive_write_open_filename(archiveWriter, archiveURL.path) == ARCHIVE_OK else {
            throw CompressionError.archiveCreationFailed
        }

        for filePath in filePaths {
            let fileURL = URL(fileURLWithPath: filePath)
            guard let file = fopen(fileURL.path, "rb") else {
                throw CompressionError.inputFileOpenFailed
            }

            let entry = archive_entry_new()
            let fileName = fileURL.lastPathComponent.data(using: .utf8)
            fileName?.withUnsafeBytes { (unsafeBufferPointer) in
                if let unsafePointer = unsafeBufferPointer.baseAddress?.assumingMemoryBound(to: CChar.self) {
                    archive_entry_set_pathname(entry, unsafePointer)
                }
            }

            var fileData = CompressionFileData(file: file)
            archive_entry_set_size(entry, la_int64_t(UInt64(fileData.fileSize)))
            archive_write_header(archiveWriter, entry)

            while archive_write_data(archiveWriter, fileData.buffer, fileData.bytesRead) == ARCHIVE_OK {
                fileData.readNextChunk()
            }

            archive_entry_free(entry)
            fclose(file)
        }

        archive_write_close(archiveWriter)
        archive_write_free(archiveWriter)
    }
    
    private class func compressFileC(filePath: String, destination: String, type: CompressionType) throws {
        let archiveWriter = archive_write_new()
        archive_write_set_format_pax_restricted(archiveWriter)
        
        print(filePath)

        switch type {
        case .zip:
            do {
                try Zip.zipFiles(paths: [URL(fileURLWithPath: filePath)], zipFilePath: URL(fileURLWithPath: destination), password: nil, progress: nil)
            } catch {
                throw CompressionError.archiveWriteHeaderFailed
            }
        case .gz:
            archive_write_add_filter_gzip(archiveWriter)
        case .lz4:
            archive_write_add_filter_lz4(archiveWriter)
        case .bz2:
            archive_write_add_filter_bzip2(archiveWriter)
        case .xz:
            archive_write_add_filter_xz(archiveWriter)
        case .zstd:
            archive_write_add_filter_zstd(archiveWriter)
        case .lzma:
            archive_write_add_filter_lzma(archiveWriter)
        default:
            throw CompressionError.incorrectCompressionType
        }

        archive_write_add_filter_zstd(archiveWriter)

        let destinationURL = URL(fileURLWithPath: destination)
        if archive_write_open_filename(archiveWriter, destinationURL.path) != ARCHIVE_OK {
            return
        }

        let fileURL = URL(fileURLWithPath: filePath)
        let file = fopen(fileURL.path, "rb")

        let entry = archive_entry_new()
        if let fileName = fileURL.lastPathComponent.data(using: .utf8) {
            fileName.withUnsafeBytes { (unsafeBufferPointer) in
                if let unsafePointer = unsafeBufferPointer.baseAddress?.assumingMemoryBound(to: CChar.self) {
                    archive_entry_set_pathname(entry, unsafePointer)
                }
            }
        }

        if let file2 = file {
            var fileData = CompressionFileData(file: file2)
            archive_entry_set_size(entry, la_int64_t(UInt64(fileData.fileSize)))
            archive_write_header(archiveWriter, entry)
            while archive_write_data(archiveWriter, fileData.buffer, fileData.bytesRead) == ARCHIVE_OK {
                fileData.readNextChunk()
            }
        } else {
            throw CompressionError.inputFileOpenFailed
        }
        archive_entry_free(entry)
        fclose(file)

        archive_write_close(archiveWriter)
        archive_write_free(archiveWriter)
    }
    
    private class func decompressFileC(filePath: String, destination: String) throws {
        let archiveReader = archive_read_new()
        archive_read_support_filter_all(archiveReader)
        archive_read_support_format_all(archiveReader)

        let compressedFileURL = URL(fileURLWithPath: filePath)
        guard archive_read_open_filename(archiveReader, compressedFileURL.path, Int(compressedFileURL.path.count + 1)) == ARCHIVE_OK else {
            throw CompressionError.archiveReadHeaderFailed
        }

        while true {
            var entry = archive_entry_new()
            let readResult = archive_read_next_header(archiveReader, &entry)

            if readResult == ARCHIVE_EOF {
                break
            } else if readResult != ARCHIVE_OK {
                throw CompressionError.archiveReadHeaderFailed
            }

            let destinationURL = URL(fileURLWithPath: destination)
            guard let destinationFile = fopen(destinationURL.path, "wb") else {
                throw CompressionError.archiveReadHeaderFailed
            }

            var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 8192)
            defer {
                buffer.deallocate()
            }

            while true {
                let bytesRead = archive_read_data(archiveReader, buffer, 8192)

                if bytesRead == ARCHIVE_EOF {
                    break
                } else if bytesRead < 0 {
                    throw CompressionError.archiveReadDataFailed
                }

                fwrite(buffer, 1, bytesRead, destinationFile)
            }

            fclose(destinationFile)
            archive_entry_free(entry)
        }

        archive_read_close(archiveReader)
        archive_read_free(archiveReader)
    }

    private class func compressZstdC(filePaths: [String], destination: String) throws {
        let archiveWriter = archive_write_new()
        archive_write_set_format_pax_restricted(archiveWriter)

        archive_write_add_filter_zstd(archiveWriter)

        let destinationURL = URL(fileURLWithPath: destination)
        if archive_write_open_filename(archiveWriter, destinationURL.path) != ARCHIVE_OK {
            return
        }

        for filePath in filePaths {
            let fileURL = URL(fileURLWithPath: filePath)
            guard let file = fopen(fileURL.path, "rb") else {
                continue
            }

            let entry = archive_entry_new()
            if let fileName = fileURL.lastPathComponent.data(using: .utf8) {
                fileName.withUnsafeBytes { (unsafeBufferPointer) in
                    if let unsafePointer = unsafeBufferPointer.baseAddress?.assumingMemoryBound(to: CChar.self) {
                        archive_entry_set_pathname(entry, unsafePointer)
                    }
                }
            }

            var fileData = CompressionFileData(file: file)
            archive_entry_set_size(entry, la_int64_t(UInt64(fileData.fileSize)))
            archive_write_header(archiveWriter, entry)
            while archive_write_data(archiveWriter, fileData.buffer, fileData.bytesRead) == ARCHIVE_OK {
                fileData.readNextChunk()
            }
            archive_entry_free(entry)
            fclose(file)
        }

        archive_write_close(archiveWriter)
        archive_write_free(archiveWriter)
    }
    
    private class func decompressZstdC(filePath: String, destination: String) throws {
        let archiveReader = archive_read_new()
        archive_read_support_filter_zstd(archiveReader)
        archive_read_support_format_all(archiveReader)

        let archiveURL = URL(fileURLWithPath: filePath)
        guard archive_read_open_filename(archiveReader, archiveURL.path, Int(archiveURL.path.count + 1)) == ARCHIVE_OK else {
            throw CompressionError.archiveReadHeaderFailed
        }

        while true {
            var entry = archive_entry_new()
            let readResult = archive_read_next_header(archiveReader, &entry)

            if readResult == ARCHIVE_EOF {
                break
            } else if readResult != ARCHIVE_OK {
                throw CompressionError.archiveReadHeaderFailed
            }

            let entryPathname = String(cString: archive_entry_pathname(entry))
            let destinationFilePath = (destination as NSString).appendingPathComponent(entryPathname)

            let destinationFileURL = URL(fileURLWithPath: destinationFilePath)
            let destinationDirectoryURL = destinationFileURL.deletingLastPathComponent()
            do {
                try FileManager.default.createDirectory(at: destinationDirectoryURL, withIntermediateDirectories: true)
            } catch {
                throw CompressionError.archiveWriteDataFailed
            }

            guard let destinationFile = fopen(destinationFileURL.path, "wb") else {
                throw CompressionError.archiveReadHeaderFailed
            }

            var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 8192)
            defer {
                buffer.deallocate()
            }

            while true {
                let bytesRead = archive_read_data(archiveReader, buffer, 8192)

                if bytesRead == ARCHIVE_EOF {
                    break
                } else if bytesRead < 0 {
                    throw CompressionError.archiveReadDataFailed
                }

                fwrite(buffer, 1, bytesRead, destinationFile)
            }

            fclose(destinationFile)
            archive_entry_free(entry)
        }

        archive_read_close(archiveReader)
        archive_read_free(archiveReader)
    }
}
