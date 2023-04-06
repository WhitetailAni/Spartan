//
//  VideoPlayerView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI
import Foundation
import AVFAudio
import AVFoundation
import AVKit

struct VideoPlayerView: View {
    @Binding var videoPath: String
    @State private var player = AVPlayer()
    @State private var isPlaying = false
    @State private var duration: Double = 0
    @State private var currentTime: Double = 0
    @State private var rewindIncrement = 1
    @State private var fastIncrement = 1
    @State private var endShow = false
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            playerView
            controlsView
        }
        .onReceive(player.publisher(for: \.timeControlStatus)) { timeControlStatus in
            isPlaying = timeControlStatus == .playing
        }
        .onReceive(player.publisher(for: \.currentItem)) { item in
            guard let item = item else { return }
            duration = item.duration.seconds
        }
    }
    
    var playerView: some View {
        VideoPlayer(player: player)
            .onAppear {
                let url = URL(fileURLWithPath: videoPath)
                print(videoPath)
                print(url)
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                player.play()
            }
            .onReceive(timer) { _ in
                currentTime = player.currentTime().seconds
            }
            .onReceive(player.publisher(for: \.timeControlStatus)) { timeControlStatus in
                isPlaying = timeControlStatus == .playing
            }
            .focusable(true)
    }
    
    var controlsView: some View {
        VStack{
            HStack {
                backwardButton
                timeLabel
                forwardButton
            }
            HStack {
                videoStartButton
                Spacer()
                rewindButton
                playPauseButton
                fastForwardButton
                Spacer()
                videoInfoButton
            }
        }
        .padding(.horizontal)
        .onPlayPauseCommand {
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
            isPlaying.toggle()
        }
    }
    
    @ViewBuilder
    var backwardButton: some View {
        Button(action: {
            let newTime = max(player.currentTime() - CMTime(seconds: 10, preferredTimescale: 1), CMTime.zero)
            player.seek(to: newTime)
        }) {
            Image(systemName: "gobackward.10")
                .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder
    var timeLabel: some View {
        Text(timeString(time: currentTime))
    }
    
    @ViewBuilder
    var forwardButton: some View {
        Button(action: {
            let newTime = min(player.currentTime() + CMTime(seconds: 10, preferredTimescale: 1), player.currentItem!.duration)
            player.seek(to: newTime)
        }) {
            Image(systemName: "goforward.10")
                .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder
    var videoStartButton: some View {
        Button(action: {
            let newTime = max(player.currentTime() - player.currentTime(), CMTime.zero)
            player.seek(to: newTime)
        }) {
            let time = max(player.currentTime(), CMTime.zero)
            let newTime = max(player.currentTime() - player.currentTime(), CMTime.zero)
            Image(systemName: time > newTime ? "backward.end.fill" : "backward.end")
                .resizable()
                .frame(width:36, height:32)
                .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder
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
    
    @ViewBuilder
    var playPauseButton: some View {
        Button(action: {
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
            isPlaying.toggle()
        }) {
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .resizable()
                .frame(width:50, height:50)
                .foregroundColor(.accentColor)
        }
    }
    
    @ViewBuilder
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
        
    @ViewBuilder
    var videoInfoButton: some View {
        Button(action: {
            endShow = true
        }) {
            Image(systemName: "info.circle")
                .resizable()
                .frame(width:36, height:32)
                .foregroundColor(.accentColor)
        }
        .alert(isPresented: $endShow) {
            Alert(
                title: Text(videoPath),
                message: Text(getVideoInfo(atPath: videoPath)),
                dismissButton: .default(Text(""))
            )
        }
    }

    private func timeString(time: Double) -> String {
        let date = Date(timeIntervalSince1970: time)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = time < 3600 ? "mm:ss" : "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    func getVideoInfo(atPath filePath: String) -> String {
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: fileURL)
        let duration = asset.duration.seconds
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return "Error: Could not get video track"
        }
        let width = videoTrack.naturalSize.width
        let height = videoTrack.naturalSize.height
    
        //let metadata = asset.metadata
        
        let info = """
        Video file: \(fileURL.lastPathComponent)
        Duration: \(duration) seconds
        Dimensions: \(width) x \(height) pixels
        """
        return info
    }
}

extension Color {
    init(hex: Int, opacity: Double = 1.0) {
        let red = Double((hex & 0xff0000) >> 16) / 255.0
        let green = Double((hex & 0xff00) >> 8) / 255.0
        let blue = Double((hex & 0xff) >> 0) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
