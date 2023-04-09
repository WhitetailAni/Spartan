//
//  AudioPlayerView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI
import AVKit

struct AudioPlayerView: View {
    @Binding var audioPath: String
    @State private var player = AVAudioPlayer()
    
    @State private var rewindIncrement = 1
    @State private var fastIncrement = 1
    @State private var isPlaying = false
    
    var body: some View {
        HStack {
            rewindButton
            Button(action: {
                if isPlaying {
                    isPlaying = false
                } else {
                    isPlaying = true
                }
                guard let escapedFilePath = audioPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                      let url = URL(string: "file://\(escapedFilePath)")
                else {
                    print("Invalid URL: \(audioPath)")
                    return
                }
                let playerItem = AVPlayerItem(url: url)
                let player = AVPlayer(playerItem: playerItem)
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                player.play()
            }) {
                Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                    .font(.system(size: 64))
            }
            fastForwardButton
        }
    }
    
    var rewindButton: some View {
        Button(action: {
            if rewindIncrement == 1 {
                player.rate = -1.0
            } else if rewindIncrement == 2 {
                player.rate = -2.0
            } else if rewindIncrement == 3 {
                player.rate = -4.0
            } else if rewindIncrement == 4 {
                player.rate = -8.0
            } else if rewindIncrement == 5 {
                player.rate = 1.0
            }
            if(rewindIncrement == 5){
                rewindIncrement = 1
            } else {
                rewindIncrement += 1
            }
        }) {
            Image(systemName: player.rate < 0.0 ? "backward.fill" : "backward")
                .resizable()
                .frame(width:54, height:31)
                .foregroundColor(.accentColor)
        }
    }
    
    var fastForwardButton: some View {
        Button(action: {
            if fastIncrement == 1 {
                player.rate = 2.0
            } else if fastIncrement == 2 {
                player.rate = 4.0
            } else if fastIncrement == 3 {
                player.rate = 8.0
            } else if fastIncrement == 4 {
                player.rate = 1.0
            }
            if(fastIncrement == 4){
                fastIncrement = 1
            } else {
                fastIncrement += 1
            }
        }) {
            Image(systemName: player.rate > 1.0 ? "forward.fill" : "forward")
                .resizable()
                .frame(width:54, height:31)
                .foregroundColor(.accentColor)
        }
    }
}
