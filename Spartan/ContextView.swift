//
//  ContextView.swift
//  Spartan
//
//  Created by RealKGB on 4/23/23.
//

import SwiftUI

struct ContextView: View {

    @State var openInMenu = false
    
    //TONS of binding vars to link back to ContentView.
    //kill me.
    @Binding var index: Int
    @Binding var directory: String
    @Binding var files: [String]
    
    @Binding var fileInfoShow: Bool
    @Binding var fileInfo: String
    
    @Binding var newViewFilePath: String
    @Binding var newViewArrayNames: [String]
    
    @Binding var renameFileCurrentName: String
    @Binding var renameFileNewName: String
    @Binding var renameFileShow: Bool
    
    @Binding var addToFavoritesDisplayName: String
    @Binding var moveFileShow: Bool
    @Binding var copyFileShow: Bool
    @Binding var addToFavoritesShow: Bool
    @Binding var deleteOverride: Bool
    
    @Binding var multiSelect: Bool
    @Binding var permissionDenied: Bool
    @Binding var multiSelectFiles: [String]
    @Binding var fileWasSelected: [Bool]
    
    @Binding var audioPlayerShow: Bool
    @Binding var callback: Bool
    @Binding var newViewFileName: String
    @Binding var videoPlayerShow: Bool
    @Binding var imageShow: Bool
    @Binding var textShow: Bool
    @Binding var plistShow: Bool
    @Binding var spawnShow: Bool
    
    @Binding var zipFileShow: Bool
    @Binding var uncompressZip: Bool
    
    @Binding var selectedFile: FileInfo?

    var body: some View {
        HStack {
            mainMenu                
            if (openInMenu) {
                openIn
            }
        }
    }
    
    @ViewBuilder
    var mainMenu: some View {
        Button(action: {
                defaultAction(index: index)
            }) {
                Text(NSLocalizedString("OPEN", comment: "You ever think maybe things work a little too well here?"))
            }
        
            Button(action: {
                fileInfoShow = true
                fileInfo = getFileInfo(forFileAtPath: directory + files[index])
            }) {
                Text(NSLocalizedString("INFO", comment: "there is no way a bee should be able to fly."))
            }
            .disabled(openInMenu)
            
            Button(action: {
                newViewFilePath = directory
                renameFileCurrentName = files[index]
                renameFileNewName = files[index]
                renameFileShow = true
            }) {
                Text(NSLocalizedString("RENAME", comment: "Its wings are too small to get its fat little body off the ground."))
            }
            .disabled(openInMenu)
            
            Button(action: {
                openInMenu = true
                newViewFilePath = directory
                newViewArrayNames = [files[index]]
            }) {
                Text(NSLocalizedString("OPENIN", comment: "The bee, of course, flies anyway"))
            }
            .disabled(openInMenu)
            
            if(directory == "/var/mobile/Media/.Trash/"){
                Button(action: {
                    deleteFile(atPath: directory + files[index])
                    updateFiles()
                }) {
                    Text(NSLocalizedString("DELETE", comment: "because bees don't care what humans think is impossible."))
                }
                .foregroundColor(.red)
                .disabled(openInMenu)
            } else if(directory == "/var/mobile/Media/" && files[index] == ".Trash/"){
                Button(action: {
                    do {
                        try FileManager.default.removeItem(atPath: "/var/mobile/Media/.Trash/")
                    } catch {
                        print("Error emptying Trash: \(error)")
                    }
                    do {
                        try FileManager.default.createDirectory(atPath: "/var/mobile/Media/.Trash/", withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("Error emptying Trash: \(error)")
                    }
                    
                }) {
                    Text(NSLocalizedString("TRASHYEET", comment: "Yellow, black. Yellow, black."))
                }
                .disabled(openInMenu)
            } else {
                Button(action: {
                    moveFile(path: directory + files[index], newPath: ("/var/mobile/Media/.Trash/" + files[index]))
                    updateFiles()
                }) {
                    Text(NSLocalizedString("GOTOTRASH", comment: "Yellow, black. Yellow, black."))
                }
                .disabled(openInMenu)
            }
            if(deleteOverride){
                Button(action: {
                    deleteFile(atPath: directory + files[index])
                    updateFiles()
                }) {
                    Text(NSLocalizedString("DELETE", comment: "Ooh, black and yellow!"))
                }
                .foregroundColor(.red)
                .disabled(openInMenu)
            }
            
            Button(action: {
                addToFavoritesShow = true
                newViewFilePath = directory + files[index]
                if files[index].hasSuffix("/") {
                    addToFavoritesDisplayName = String(substring(str: files[index], startIndex: files[index].index(files[index].startIndex, offsetBy: 0), endIndex: files[index].index(files[index].endIndex, offsetBy: -1)))
                } else {
                    addToFavoritesDisplayName = files[index]
                }
                UserDefaults.favorites.synchronize()
            }) {
                Text(NSLocalizedString("FAVORITESADD", comment: "Let's shake it up a little."))
            }
            .disabled(openInMenu)
            
            Button(action: {
                newViewFilePath = directory
                newViewArrayNames = [files[index]]
                moveFileShow = true
            }) {
                Text(NSLocalizedString("MOVETO", comment: "Barry! Breakfast is ready!"))
            }
            
            Button(action: {
                newViewFilePath = directory
                newViewArrayNames = [files[index]]
                copyFileShow = true
            }) {
                Text(NSLocalizedString("COPYTO", comment: "Coming!"))
            }
            
            Button(NSLocalizedString("DISMISS", comment: "Hang on a second.")) { }
    }
    
    @ViewBuilder
    var openIn: some View {
        Button(action: {
                    directory = directory + files[index]
                    updateFiles()
                    print(directory)
                }) {
                    Text(NSLocalizedString("OPEN_DIRECTORY", comment: "Hello?"))
                }
                
                Button(action: {
                    audioPlayerShow = true
                    callback = true
                    newViewFilePath = directory + files[index]
                    newViewFileName = files[index]
                }) {
                    Text(NSLocalizedString("OPEN_AUDIO", comment: "- Barry?"))
                }
                
                Button(action: {
                    videoPlayerShow = true
                    newViewFilePath = directory + files[index]
                    newViewFileName = files[index]
                }) {
                    Text(NSLocalizedString("OPEN_VIDEO", comment: "- Adam?"))
                }
                
                Button(action: {
                    imageShow = true
                    newViewFilePath = directory + files[index]
                }) {
                    Text(NSLocalizedString("OPEN_IMAGE", comment: "- Can you believe this is happening?"))
                }
                
                Button(action: {
                    textShow = true
                    newViewFilePath = directory + files[index]
                }) {
                    Text(NSLocalizedString("OPEN_TEXT", comment: "- I can't. I'll pick you up."))
                }
                
                Button(action: {
                    plistShow = true
                    newViewFilePath = directory + files[index]
                    newViewFileName = files[index]
                }) {
                    Text(NSLocalizedString("OPEN_PLIST", comment: "Looking sharp."))
                }
                
                Button(action: {
                    spawnShow = true
                    newViewFilePath = directory + files[index]
                }) {
                    Text(NSLocalizedString("OPEN_SPAWN", comment: "Use the stairs. Your father paid good money for those."))
                }
                
                Button(NSLocalizedString("DISMISS", comment: "Sorry. I'm excited.")) { }
    }
    
    func defaultAction(index: Int) {
        if (multiSelect) {
            if(fileWasSelected[index]){
                let searchedIndex = multiSelectFiles.firstIndex(of: files[index])
                multiSelectFiles.remove(at: searchedIndex!)
                fileWasSelected[index] = false
                print(multiSelectFiles)
            } else {
                fileWasSelected[index] = true
                multiSelectFiles.append(files[index])
                print(multiSelectFiles)
            }
        } else {
            multiSelect = false
            if (yandereDevFileType(file: (directory + files[index])) == 0) {
                directory = directory + files[index]
                updateFiles()
                print(directory)
            } else if (yandereDevFileType(file: (directory + files[index])) == 1) {
                audioPlayerShow = true
                callback = true
                newViewFilePath = directory + files[index]
                newViewFileName = files[index]
            } else if (yandereDevFileType(file: (directory + files[index])) == 2){
                videoPlayerShow = true
                newViewFilePath = directory + files[index]
                newViewFileName = files[index]
            } else if (yandereDevFileType(file: (directory + files[index])) == 3) {
                imageShow = true
                newViewFilePath = directory + files[index]
            } else if (yandereDevFileType(file: (directory + files[index])) == 4) {
                textShow = true
                newViewFilePath = directory + files[index]
            } else if (yandereDevFileType(file: (directory + files[index])) == 5){
                plistShow = true
                newViewFilePath = directory + files[index]
                newViewFileName = files[index]
            } else if (yandereDevFileType(file: (directory + files[index])) == 6){
                zipFileShow = true
                newViewFileName = files[index]
                uncompressZip = true
            } else if (yandereDevFileType(file: (directory + files[index])) == 7){
                spawnShow = true
                newViewFilePath = directory + files[index]
            } else {
                selectedFile = FileInfo(name: files[index], id: UUID())
            }
        }
    }
    
    func yandereDevFileType(file: String) -> Int { //I tried using unified file types but they all returned nil so I have to use this awful yandere dev shit
        //im sorry
        
        let audioTypes: [String] = ["aifc", "m4r", "wav", "flac", "m2a", "aac", "mpa", "xhe", "aiff", "amr", "caf", "m4a", "m4r", "m4b", "mp1", "m1a", "aax", "mp2", "w64", "m4r", "aa", "mp3", "au", "eac3", "ac3", "m4p", "loas"]
        let videoTypes: [String] = ["3gp", "3g2", "avi", "mov", "m4v", "mp4"]
        let imageTypes: [String] = ["png", "tiff", "tif", "jpeg", "jpg", "gif", "bmp", "BMPf", "ico", "cur", "xbm"]
        let archiveTypes: [String] = ["zip", "cbz"]
    
        if file.hasSuffix("/") {
            return 0 //directory
        } else if (audioTypes.contains(where: file.hasSuffix)) {
            return 1 //audio file
        } else if (videoTypes.contains(where: file.hasSuffix)) {
            return 2 //video file
        } else if (imageTypes.contains(where: file.hasSuffix)) {
            return 3 //image
        } else if (isText(filePath: file)) {
            return 4 //text file
        } else if (isPlist(filePath: file)) {
            return 5 //plist
        } else if (archiveTypes.contains(where: file.hasSuffix)){
            return 6 //archive
        } else if (FileManager.default.isExecutableFile(atPath: file)) {
            return 7 //executable
        //} else if (URL(fileURLWithPath: file).isSymbolicLink()) {
          //  return 8 //symlink
        } else {
            return 69 //unknown
        }
    }
    
    func isText(filePath: String) -> Bool {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return false // File does not exist or cannot be read
        }
    
        let isASCII = data.allSatisfy {
            Character(UnicodeScalar($0)).isASCII
        }
        let isUTF8 = String(data: data, encoding: .utf8) != nil
    
        return isASCII || isUTF8
    }
    
    func isPlist(filePath: String) -> Bool {
        guard let data = FileManager.default.contents(atPath: filePath) else {
            return false // File does not exist or cannot be read
        }
    
        let headerSize = 8
        let header = data.prefix(headerSize)
        let isXMLPlist = header.starts(with: [60, 63, 120, 109, 108]) // "<?xml"
        let isBinaryPlist = header.starts(with: [98, 112, 108, 105, 115, 116, 48, 48]) // "bplist00"
    
        return isXMLPlist || isBinaryPlist
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
            resizeMultiSelectArrays()
            resetMultiSelectArrays()
        } catch {
            print(error)
            if(substring(str: error.localizedDescription, startIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: -33), endIndex: error.localizedDescription.index(error.localizedDescription.endIndex, offsetBy: 0)) == "don’t have permission to view it."){
                permissionDenied = true
                multiSelect = false
                goBack()
            }
        }
    }
    
    func goBack() {
        guard directory != "/" else {
            return
        }
        var components = directory.split(separator: "/")
    
        if components.count > 1 {
            components.removeLast()
            directory = "/" + components.joined(separator: "/") + "/"
        } else if components.count == 1 {
            directory = "/"
        }
        multiSelect = false
        updateFiles()
    }
    
    public func substring(str: String, startIndex: String.Index, endIndex: String.Index) -> Substring {
        let range: Range = startIndex..<endIndex
        return str[range]
    }
    
    public func deleteFile(atPath path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch {
            print("Failed to delete file: \(error.localizedDescription)")
        }
    }
    
    public func getFileInfo(forFileAtPath: String) -> String {
        let fileManager = FileManager.default
    
        do {
            let attributes = try fileManager.attributesOfItem(atPath: forFileAtPath)
    
            let creationDate = attributes[.creationDate] as? Date ?? Date.distantPast
            let modificationDate = attributes[.modificationDate] as? Date ?? Date.distantPast
            
            let fileSize = attributes[.size] as? Int ?? 0
            
            @State var fileOwner: String = ((attributes[.ownerAccountName] as? String)!)
            
            let fileOwnerID = attributes[.groupOwnerAccountID] as? Int ?? 0
            let filePerms = String(format: "%03d", attributes[.posixPermissions] as? Int ?? "000")
            

            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            let fileInfoString = """
            \(NSLocalizedString("INFO_PATH", comment: "Ma! I got a thing going here.") + forFileAtPath)
            \(NSLocalizedString("INFO_SIZE", comment: "- You got lint on your fuzz.") + ByteCountFormatter().string(fromByteCount: Int64(fileSize)))
            \(NSLocalizedString("INFO_CREATION", comment: "- Ow! That's me!") + dateFormatter.string(from: creationDate))
            \(NSLocalizedString("INFO_MODIFICATION", comment: "- Wave to us! We'll be in row 118,000.") + dateFormatter.string(from: modificationDate))
            \(NSLocalizedString("INFO_OWNER", comment: "- Bye!") + fileOwner)
            \(NSLocalizedString("INFO_OWNERID", comment: "Barry, I told you, stop flying in the house!") + String(fileOwnerID))
            \(NSLocalizedString("INFO_PERMISSIONS", comment: "- Hey, Adam.") + filePerms)
            """

            return fileInfoString
        } catch {
            return "Error: \(error.localizedDescription)"
        }
    }
    
    func moveFile(path: String, newPath: String) {
        do {
            try FileManager.default.moveItem(atPath: path, toPath: newPath)
        } catch {
            print("Failed to move file: \(error.localizedDescription)")
        }
    }
    
    func resizeMultiSelectArrays() {
        let range = abs(files.count - fileWasSelected.count)
        if(fileWasSelected.count > files.count){
            fileWasSelected.removeLast(range)
            if(fileWasSelected.count == 0){
                fileWasSelected.append(false)
            }
        } else if(fileWasSelected.count < files.count){
            for _ in 0..<range {
                fileWasSelected.append(false)
            }
        }
    }
    func resetMultiSelectArrays(){
        iterateOverFileWasSelected(boolToIterate: false)
        for i in 0..<multiSelectFiles.count {
            multiSelectFiles[i] = ""
        }
    }
    func iterateOverFileWasSelected(boolToIterate: Bool) {
        for i in 0..<fileWasSelected.count {
            fileWasSelected[i] = boolToIterate
        }
    }
}
