//
//  Compression.swift
//  Spartan
//
//  Created by WhitetailAni on 12/1/23.
//

import Foundation
import libarchiveBridge
import Zip

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
        }
    }
}

class Compression {
    class func compressFile(filePath: String, destination: String, compType: CompressionType, tarCompType: TarCompressionType) throws {
        switch compType {
        case .tar:
            do {
                try createTarC(files: [filePath], destination: tempPath)
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
                try compressFileC(filePath: filePath, destination: destination, type: compType)
            } catch {
                throw error
            }
        }
    }
    
    class func compressFiles(listOfFiles: [String], destination: String, compType: CompressionType, tarCompType: TarCompressionType = .none) throws {
        var stringList = ""
        for file in listOfFiles {
            stringList += "\(file) "
        }
        
        switch compType {
        case .zip:
            do {
                var urls: [URL] = []
                for file in listOfFiles {
                    urls.append(URL(fileURLWithPath: file))
                }
                try Zip.zipFiles(paths: urls, zipFilePath: URL(fileURLWithPath: destination), password: nil, progress: nil)
            } catch {
                throw CompressionError.archiveWriteHeaderFailed
            }
        case .zstd:
            do {
                try compressZstdC(filePaths: listOfFiles, destination: destination)
            } catch {
                throw error
            }
        case .tar:
            do {
                try createTarC(files: listOfFiles, destination: tempPath)
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
    
    private class func createTarC(files: [String], destination: String) throws {
        let archive = archive_write_new()
        defer { archive_write_free(archive) }

        archive_write_add_filter_none(archive)
        archive_write_set_format_ustar(archive)

        guard archive_write_open_filename(archive, destination) == ARCHIVE_OK else {
            throw CompressionError.outputFileOpenFailed
        }

        for filePath in files {
            let entry = archive_entry_new()
            defer { archive_entry_free(entry) }

            archive_entry_copy_pathname(entry, filePath)

            archive_entry_set_filetype(entry, UInt32(AE_IFREG))

            guard archive_write_header(archive, entry) == ARCHIVE_OK else {
                throw CompressionError.archiveWriteHeaderFailed
            }

            guard let file = try? FileHandle(forReadingFrom: URL(fileURLWithPath: filePath)) else {
                throw CompressionError.inputFileOpenFailed
            }
            defer { file.closeFile() }

            var data = file.readData(ofLength: 4096)
            while !data.isEmpty {
                do {
                    try data.withUnsafeBytes { bufferPointer in
                        guard archive_write_data(archive, bufferPointer.baseAddress, data.count) == data.count else {
                            throw CompressionError.archiveWriteDataFailed
                        }
                    }
                    data = file.readData(ofLength: 4096)
                } catch {
                    throw CompressionError.archiveWriteDataFailed
                }
            }

            guard archive_write_finish_entry(archive) == ARCHIVE_OK else {
                throw CompressionError.archiveFinishEntryFailed
            }
        }
    }
    
    private class func compressFileC(filePath: String, destination: String, type: CompressionType) throws {
        let archive = archive_write_new()
        defer { archive_write_free(archive) }

        switch type {
        case .zip:
            do {
                try Zip.zipFiles(paths: [URL(fileURLWithPath: filePath)], zipFilePath: URL(fileURLWithPath: destination), password: nil, progress: nil)
            } catch {
                throw CompressionError.archiveWriteHeaderFailed
            }
        case .gz:
            archive_write_add_filter_gzip(archive)
        case .lz4:
            archive_write_add_filter_lz4(archive)
        case .bz2:
            archive_write_add_filter_bzip2(archive)
        case .xz:
            archive_write_add_filter_xz(archive)
        case .zstd:
            archive_write_add_filter_zstd(archive)
        case .lzma:
            archive_write_add_filter_lzma(archive)
        default:
            throw CompressionError.incorrectCompressionType
        }

        guard archive_write_open_filename(archive, destination) == ARCHIVE_OK else {
            throw CompressionError.outputFileOpenFailed
        }

        let entry = archive_entry_new()
        defer { archive_entry_free(entry) }

        archive_entry_copy_pathname(entry, filePath)

        guard archive_write_header(archive, entry) == ARCHIVE_OK else {
            throw CompressionError.archiveWriteHeaderFailed
        }

        guard let file = try? FileHandle(forReadingFrom: URL(fileURLWithPath: filePath)) else {
            throw CompressionError.inputFileOpenFailed
        }
        defer { file.closeFile() }

        var data = Data(capacity: 4096)
        while file.readData(ofLength: 4096).count > 0 {
            do {
                try data.withUnsafeBytes { bufferPointer in
                    guard archive_write_data(archive, bufferPointer.baseAddress, data.count) == data.count else {
                        throw CompressionError.archiveWriteDataFailed
                    }
                }
            } catch {
                throw CompressionError.archiveWriteDataFailed
            }
            data.removeAll()
        }

        file.closeFile()

        guard archive_write_finish_entry(archive) == ARCHIVE_OK else {
            throw CompressionError.archiveFinishEntryFailed
        }
    }
    
    private class func decompressFileC(filePath: String, destination: String) throws {
        let inputPathCString = filePath.cString(using: .utf8)!
        let destinationPathCString = destination.cString(using: .utf8)!

        let archive = archive_read_new()
        defer { archive_write_free(archive) }

        archive_read_support_filter_all(archive)
        archive_read_support_format_all(archive)

        if archive_read_open_filename(archive, inputPathCString, 10240) != ARCHIVE_OK {
            archive_read_free(archive)
            throw CompressionError.inputFileOpenFailed
        }

        guard let archiveWrite = archive_write_disk_new() else {
            archive_read_free(archive)
            throw CompressionError.outputFileOpenFailed
        }

        archive_write_disk_set_options(archiveWrite, ARCHIVE_EXTRACT_PERM)
        archive_write_disk_set_standard_lookup(archiveWrite)

        while true {
            var entry: OpaquePointer?
            let result = archive_read_next_header(archive, &entry)

            if result == ARCHIVE_EOF {
                break
            }

            if result != ARCHIVE_OK {
                throw CompressionError.archiveReadHeaderFailed
            }

            archive_entry_set_pathname(entry, destinationPathCString)

            if archive_write_header(archiveWrite, entry) != ARCHIVE_OK {
                throw CompressionError.archiveReadHeaderFailed
            }

            if let entry = entry {
                var buffer = [UInt8](repeating: 0, count: 1024)

                while true {
                    let bytesRead = archive_read_data(archive, &buffer, buffer.count)
                    if bytesRead == 0 {
                        break
                    } else if bytesRead < 0 {
                        throw CompressionError.archiveReadDataFailed
                    }

                    _ = buffer.withUnsafeBytes { data in
                        archive_write_data(archiveWrite, data.baseAddress, bytesRead)
                    }
                }
            }
        }

        archive_read_close(archive)
        archive_read_free(archive)
        archive_write_close(archiveWrite)
        archive_write_free(archiveWrite)
    }
    
    private class func compressZstdC(filePaths: [String], destination: String) throws {
        guard let archive = archive_write_new() else {
            throw CompressionError.inputFileOpenFailed
        }

        archive_write_add_filter_zstd(archive)
        archive_write_set_format_pax_restricted(archive)

        let outputArchive = archive_write_open_filename(archive, destination)
        guard outputArchive != ARCHIVE_OK else {
            archive_write_free(archive)
            throw CompressionError.outputFileOpenFailed
        }

        for filePath in filePaths {
            guard let entry = archive_entry_new() else {
                throw CompressionError.archiveWriteDataFailed
            }

            archive_entry_copy_pathname(entry, filePath)
            archive_write_header(archive, entry)

            if let file = fopen(filePath, "r") {
                let bufferSize = 4096
                var buffer = [UInt8](repeating: 0, count: bufferSize)
                var bytesRead: Int

                repeat {
                    bytesRead = fread(&buffer, 1, bufferSize, file)
                    if bytesRead > 0 {
                        archive_write_data(archive, &buffer, bytesRead)
                    }
                } while bytesRead > 0

                fclose(file)
            }

            archive_entry_free(entry)
        }

        archive_write_close(archive)
        archive_write_free(archive)
    }
    
    private class func decompressZstdC(filePath: String, destination: String) throws {
        let archive = archive_write_new()
        defer { archive_write_free(archive) }

        defer { archive_read_free(archive) }

        archive_read_support_filter_zstd(archive)
        archive_read_support_format_all(archive)

        guard archive_read_open_filename(archive, filePath, 10240) == ARCHIVE_OK else {
            throw CompressionError.inputFileOpenFailed
        }

        guard let ext = archive_write_disk_new() else {
            throw CompressionError.outputFileOpenFailed
        }

        defer {
            archive_write_close(ext)
            archive_write_free(ext)
        }

        archive_write_disk_set_options(ext, ARCHIVE_EXTRACT_TIME)

        while true {
            var entry: OpaquePointer?
            let result = archive_read_next_header(archive, &entry)

            guard result != ARCHIVE_EOF else {
                break
            }

            guard result == ARCHIVE_OK else {
                throw CompressionError.archiveReadHeaderFailed
            }

            guard let currentEntry = entry else {
                throw CompressionError.archiveReadDataFailed
            }

            let entryPath = String(cString: archive_entry_pathname(currentEntry))
            let destinationFilePath = (destination as NSString).appendingPathComponent(entryPath)

            let destinationDirectory = (destinationFilePath as NSString).deletingLastPathComponent
            try FileManager.default.createDirectory(atPath: destinationDirectory, withIntermediateDirectories: true, attributes: nil)

            archive_write_disk_set_standard_lookup(ext)
            archive_write_disk_set_options(ext, ARCHIVE_EXTRACT_TIME)

            guard archive_write_header(ext, currentEntry) == ARCHIVE_OK else {
                throw CompressionError.archiveWriteHeaderFailed
            }

            guard archive_write_finish_entry(ext) == ARCHIVE_OK else {
                throw CompressionError.archiveFinishEntryFailed
            }
        }
    }
}
