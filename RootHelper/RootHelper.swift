//
//  RootHelper.swift
//  RootHelper
//
//  Created by RealKGB on 6/24/23.
//

import Foundation

@main
class main {

    static func main() async -> Void {
        print("Welcome to root helper!")
        parse()
    }

    static func parse() {
        let arguments = CommandLine.arguments
        let helper = RootHelper()
        let args = Array(arguments.dropFirst())

        switch args[0] {
        case "rm":
            helper.rm(args[1])
        case "mv":
            helper.mv(args[1], args[2])
        case "cp":
            helper.cp(args[1], args[2])
        case "tf":
            helper.touchFile(args[1])
        case "td":
            helper.touchDir(args[1])
        case "ts":
            helper.touchSym(args[1], args[2])
        case "ch":
            helper.chmod(args[1], args[2])
        default:
            print("Unknown action specified, exiting!")
        }
    }
}

class RootHelper {
    let fileManager = FileManager.default
    
    @discardableResult func rm(_ filePath: String) -> Bool {
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch {
            print("Failed to delete file: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    @discardableResult func mv(_ ogPath: String, _ newPath: String) -> Bool {
        do {
            try fileManager.moveItem(atPath: ogPath, toPath: newPath)
        } catch {
            print("Failed to move file: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    @discardableResult func cp(_ ogPath: String, _ newPath: String) -> Bool {
        do {
            try fileManager.copyItem(atPath: ogPath, toPath: newPath)
        } catch {
            print("Failed to copy file: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    @discardableResult func touchFile(_ path: String) -> Bool {
        if fileManager.fileExists(atPath: path) {
            print("File already exists at path \(path), exiting!")
            return false
        } else {
            fileManager.createFile(atPath: path, contents: nil, attributes: nil)
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }
        print("Failed to create file at path \(path)")
        return false
    }
    
    @discardableResult func touchDir(_ path: String) -> Bool {
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create directory at path \(path): \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    @discardableResult func touchSym(_ sourcePath: String, _ destPath: String) -> Bool {
        do {
            try FileManager.default.createSymbolicLink(atPath: sourcePath, withDestinationPath: destPath)
        } catch {
            print("Failed to create symlink from \(sourcePath) to \(destPath): \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    @discardableResult func chmod(_ filePath: String, _ perms: String) -> Bool {
        guard fileManager.fileExists(atPath: filePath) else {
            print("File does not exist at path: \(filePath)")
            return false
        }
        
        let fileAttributes = try! FileManager.default.attributesOfItem(atPath: filePath)
        let permissions = fileAttributes[.posixPermissions] as! NSNumber
        let oldPerms = permissions.intValue
        
        let permsPro = Int(perms) ?? oldPerms
        
        do {
            try fileManager.setAttributes([FileAttributeKey.posixPermissions: NSNumber(value: permsPro)], ofItemAtPath: filePath)
        } catch {
            print("Error changing file permissions: \(error.localizedDescription)")
            return false
        }
        return true
    }
}
