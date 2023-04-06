//
//  AudioPlayerView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @Binding var audioPath: String
    @State private var player = AVAudioPlayer()
    
    @State private var rewindIncrement = 1
    @State private var fastIncrement = 1
    
    var body: some View {
        VStack {
            rewindButton
            Button(action: play) {
                Image(systemName: "play.circle")
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
    
    func play() {
        guard let audioURL = URL(string: audioPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "") else {
            print("Invalid audio URL: \(audioPath)")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            self.player = try AVAudioPlayer(contentsOf: audioURL)
            self.player.prepareToPlay()
            self.player.play()
        } catch let error {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }
}
