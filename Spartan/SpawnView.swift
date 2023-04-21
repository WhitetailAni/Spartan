//
//  SpawnView.swift
//  Spartan
//
//  Created by RealKGB on 4/18/23.
//

import SwiftUI

class ProcessOutput: ObservableObject {
    @Published var output: String = ""
    @Published var error: String = ""
}

//this is probably done very very wrong.
//i'll steal pogo code later

struct SpawnView: View {
    @Binding var binaryPath: String
    @StateObject var processOutput = ProcessOutput()

    var body: some View {
        VStack {
            Text(processOutput.output)
            Text(processOutput.error)
        }
        .onAppear {
            let args: [UnsafeMutablePointer<CChar>?] = [strdup(binaryPath)]
            let env: [UnsafeMutablePointer<CChar>?] = []
            var fileActions = posix_spawn_file_actions_t(bitPattern: 0)
            posix_spawn_file_actions_init(&fileActions)
            let outPipe = Pipe()
            let errPipe = Pipe()
            posix_spawn_file_actions_addclose(&fileActions, outPipe.fileHandleForReading.fileDescriptor)
            posix_spawn_file_actions_addclose(&fileActions, errPipe.fileHandleForReading.fileDescriptor)
            posix_spawn_file_actions_adddup2(&fileActions, outPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
            posix_spawn_file_actions_adddup2(&fileActions, errPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
            
            var pid = pid_t()
            let spawnResult = posix_spawn(&pid, "/usr/bin/env", &fileActions, nil, args, env)
            if spawnResult == 0 {
                let outHandle = outPipe.fileHandleForReading
                let errHandle = errPipe.fileHandleForReading
                let outData = outHandle.readDataToEndOfFile()
                let errData = errHandle.readDataToEndOfFile()
                if let outString = String(data: outData, encoding: .utf8) {
                    DispatchQueue.main.async {
                        processOutput.output = outString
                    }
                }
                if let errString = String(data: errData, encoding: .utf8) {
                    DispatchQueue.main.async {
                        processOutput.error = errString
                    }
                }
            } else {
                processOutput.error = "posix_spawn failed with error code " + String(spawnResult)
            }
        }
    }
}
