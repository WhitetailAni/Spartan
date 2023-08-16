//
//  WebserverView.swift
//  Spartan
//
//  Created by RealKGB on 5/21/23.
//

import SwiftUI
import Foundation

struct WebServerView: View {
 
    @State var webdavLog: String = ""
    @State var port: UInt16 = 11111
    @State var isTapped = false

    var body: some View {
        Text("welcome to web server")
        TextField("enter port", value: $port, formatter: NumberFormatter())
        
        HStack {
            Button(action: {

            }) {
                Text("start")
                    .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                        view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                    }
                    .disabled(isTapped)
            }
            Button(action: {
                
            }) {
                Text("stop")
            }
        }
        UIKitTextView(text: $webdavLog, fontSize: CGFloat(UserDefaults.settings.integer(forKey: "logWindowFontSize")), isTapped: $isTapped)
            .onExitCommand {
                isTapped = false
            }
    }
}

/*class SFTPServer {
    private var serverSocket: Int32 = 0
    
    func start(port: UInt16) {
        // Initialize libssh2
        libssh2_init(0)
        
        // Create a server socket and bind to the specified port
        serverSocket = socket(AF_INET, SOCK_STREAM, 0)
        
        var serverAddress = sockaddr_in()
        serverAddress.sin_family = sa_family_t(AF_INET)
        serverAddress.sin_port = htons(port)
        serverAddress.sin_addr.s_addr = INADDR_ANY
        
        bind(serverSocket, UnsafePointer<sockaddr>(serverAddress), socklen_t(MemoryLayout<sockaddr_in>.size))
        
        // Listen for connections
        listen(serverSocket, SOMAXCONN)
        
        // Accept incoming connections and handle them
        while true {
            let clientSocket = accept(serverSocket, nil, nil)
            
            handleClientConnection(clientSocket)
        }
    }
    
    private func handleClientConnection(_ clientSocket: Int32) {
        let session = libssh2_session_init()
        
        guard libssh2_session_handshake(session, clientSocket) == 0 else {
            close(clientSocket)
            return
        }
        
        let sftp = libssh2_sftp_init(session)
        
        guard sftp != nil else {
            libssh2_session_disconnect(session, "Unable to initialize SFTP session")
            libssh2_session_free(session)
            close(clientSocket)
            return
        }
        
        // Handle file uploads
        while true {
            let channel = libssh2_sftp_open_ex(sftp, "/path/to/destination", UInt32("/path/to/destination".utf8.count), LIBSSH2_FXF_WRITE, 0, 0)
            
            guard channel != nil else {
                break
            }
            
            let bufferSize = 8192
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            
            while true {
                let bytesRead = read(clientSocket, buffer, bufferSize)
                
                if bytesRead > 0 {
                    let bytesWritten = libssh2_sftp_write(channel, buffer, UInt32(bytesRead))
                    
                    if bytesWritten < 0 {
                        // Handle write error
                        break
                    }
                } else {
                    // Handle read error or end of file
                    break
                }
            }
            
            libssh2_sftp_close_handle(channel)
            buffer.deallocate()
        }
        
        // Cleanup
        libssh2_sftp_shutdown(sftp)
        libssh2_session_disconnect(session, "Client disconnected")
        libssh2_session_free(session)
        close(clientSocket)
    }
}*/
