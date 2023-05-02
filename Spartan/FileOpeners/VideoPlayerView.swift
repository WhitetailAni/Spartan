//
//  VideoPlayerView2.swift
//  Spartan
//
//  Created by RealKGB on 4/12/23.
//

import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: View {
    @Binding var videoPath: String
    @Binding var videoName: String
    @Binding var isPresented: Bool
    @State var player: AVPlayer
    @State private var descriptiveTimestamps = UserDefaults.settings.bool(forKey: "verboseTimestamps")
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var rewindIncrement = 1
    @State private var fastIncrement = 1
    @State private var infoShow = false
    @State private var videoTitle: String = ""
    @State private var fullScreen = false
    
    var body: some View {
        NavigationView {
            VStack {
                if(!fullScreen) {
                    if(videoTitle == ""){
                        if(UserDefaults.settings.bool(forKey: "descriptiveTitles")){
                            Text(videoPath + videoName)
                                .font(.system(size: 40))
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding(-20)
                        } else {
                            Text(videoName)
                                .font(.system(size: 40))
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding(-20)
                        }
                    } else {
                        Text(videoTitle)
                            .font(.system(size: 40))
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(-20)
                    }
                }
                VideoPlayerRenderView(player: player)
                    .padding()
                if (!fullScreen) {
                    timeLabel
                    UIKitProgressView(value: $currentTime, total: duration)
                        .padding()
                        .transition(.opacity)
                    HStack {
                        videoStartButton
                            .transition(.opacity)
                        Spacer()
                        controlsView
                            .transition(.opacity)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                fullScreen = true
                            }
                        }) {
                            Image(systemName: "viewfinder")
                        }
                            .transition(.opacity)
                        /*Button(action: {
                            infoShow = true
                        }) {
                            Image(systemName: "info.circle")
                                .accentColor(.accentColor)
                        }
                        .alert(isPresented: $infoShow) {
                            Alert(
                                title: Text(videoPath + videoName),
                                message: Text(getVideoInfo(filePath: (videoPath + "/" + videoName))),
                                dismissButton: .default(Text(NSLocalizedString("DISMISS", comment: "- I wonder where they were.")))
                            )
                        }*/
                    }
                }
            }
        }
        .onAppear {
            player.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath: (videoPath + "/" + videoName))))
            player.play()
            
            player.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                DispatchQueue.main.async {
                    self.duration = player.currentItem?.asset.duration.seconds ?? 0
                }
            }
            player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main) { time in
                self.currentTime = time.seconds
            }
            
            guard let playerItem = player.currentItem else { return }
            let metadataList = playerItem.asset.commonMetadata

            for metadata in metadataList {
                if let commonKey = metadata.commonKey?.rawValue, commonKey == AVMetadataKey.commonKeyTitle.rawValue,
                    let title = metadata.value as? String {
                        videoTitle = title
                    }
                }
        }
        .onDisappear {
            player.pause()
        }
        .onReceive(player.publisher(for: \.timeControlStatus)) { timeControlStatus in
            isPlaying = timeControlStatus == .playing
        }
        .onExitCommand {
            if(fullScreen) {
                withAnimation {
                    fullScreen = false
                }
            } else {
                player.pause()
            }
        }
    }
    
    var controlsView: some View {
        HStack {
            rewindButton
            backwardButton
            playPauseButton
            forwardButton
            fastForwardButton
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
                .accentColor(.accentColor)
        }
    }
    
    @ViewBuilder
    var timeLabel: some View {
        if(descriptiveTimestamps) {
            Text("\(currentTime) / \(duration)")
                .font(.system(size: 30))
                .multilineTextAlignment(.leading)
        } else {
            Text("\(currentTime.format()) / \(duration.format())")
                .font(.system(size: 30))
                .multilineTextAlignment(.leading)
        }
    }
    
    @ViewBuilder
    var forwardButton: some View {
        Button(action: {
            let newTime = min(player.currentTime() + CMTime(seconds: 10, preferredTimescale: 1), player.currentItem!.duration)
            player.seek(to: newTime)
        }) {
            Image(systemName: "goforward.10")
                .accentColor(.accentColor)
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
                .accentColor(.accentColor)
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
                .accentColor(.accentColor)
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
        }) {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .frame(width:50, height:50)
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
                .accentColor(.accentColor)
        }
    }
    
    func getVideoInfo(filePath: String) -> String {
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVURLAsset(url: fileURL)
        let duration = String(format: "%.2f", asset.duration.seconds)
        let metadata = asset.metadata
        
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            return NSLocalizedString("VIDEO_ERROR", comment: "Will we pick ourjob today?")
        }
        
        let width = videoTrack.naturalSize.width
        let height = videoTrack.naturalSize.height
        let width2 = String(format: "%.1f", width)
        let height2 = String(format: "%.1f", height)
    
        for item in metadata {
            if let key = item.commonKey?.rawValue, let value = item.value {
                print("\(key): \(value)")
            }
        }
        
        let info = """
        \(NSLocalizedString("VIDEO_FILE", comment: "I heard it's just orientation.") + fileURL.lastPathComponent)
        \(NSLocalizedString("VIDEO_DURATION", comment: "Heads up! Here we go.") + duration) \(NSLocalizedString("SECONDS", comment: ""))
        \(NSLocalizedString("DIMENSIONS", comment: "Keep your hands and antennas inside the tram at all times.") + width2) x \(height2) pixels
        """
        //add support for stating more than just seconds (base off of descriptiveTimestamps)
        return info
    }
}

struct VideoPlayerRenderView: UIViewControllerRepresentable {
    @State var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.player?.rate = 1.0
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        player.play()
        uiViewController.player = player
    }
}
