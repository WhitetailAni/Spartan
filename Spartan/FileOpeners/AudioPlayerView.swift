//
//  AudioPlayerView.swift
//  Spartan
//
//  Created by RealKGB on 4/5/23.
//

import SwiftUI
import AVKit
import AVFoundation

struct AudioPlayerView: View {
    @State var callback = false
    @Binding var audioPath: String
    @Binding var audioName: String
    @State var cementedAudioPath: String = ""
    @State var cementedAudioName: String = ""
    @State var player: AVPlayer
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State public var duration: TimeInterval = 0
    @State private var descriptiveTimestamps = UserDefaults.settings.bool(forKey: "verboseTimestamps")
    @State private var loop = false
    @State private var audioData: [String] = Array(repeating: "", count: 8)
    @State private var audioArtwork: UIImage?
    @State var buttonIsFocused = false
    @State var metadataTitles: [String] = [NSLocalizedString("ALBUM", comment: "- Wonder what it'll be like?"), NSLocalizedString("ARTIST", comment: "- A little scary."), NSLocalizedString("ALBUMARTIST", comment: "Welcome to Honex, a division of Honesco"), NSLocalizedString("GENRE", comment: "and a part of the Hexagon Group."), NSLocalizedString("YEAR", comment: "This is it!"), NSLocalizedString("TRACKNUMBER", comment: "Wow."), NSLocalizedString("DISCNUMBER", comment: "Wow."), NSLocalizedString("BPM", comment: "We know that you, as a bee, have worked your whole life")]
    
    @Binding var isPresented: Bool
    
    //i love bad SVG support
    @State var buttonWidth: CGFloat = 0
    @State var buttonHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if(duration == 0 || audioPath == ""){
                        Text(NSLocalizedString("AUDIO_ERROR", comment: "to get to the point where you can work for your whole life."))
                                .font(.system(size: 40))
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding()
                    } else if(audioData[0] == ""){
                        if(UserDefaults.settings.bool(forKey: "descriptiveTitles")){
                            Text(cementedAudioPath)
                                .font(.system(size: 40))
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding()
                        } else {
                            Text(cementedAudioName)
                                .font(.system(size: 40))
                                .bold()
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    } else {
                        Text(audioData[0])
                            .font(.system(size: 40))
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    Image(uiImage: audioArtwork ?? UIImage(named: "NotFound")!)
                        .resizable()
                        .frame(width: 543, height: 543)
                        .padding()
                }
                
                VStack {
                    if(descriptiveTimestamps) {
                        Text("\(currentTime) / \(duration)")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("\(currentTime.format()) / \(duration.format())")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }
                    Text("")
                    ForEach(1..<audioData.count, id: \.self) { index in
                        if(!(audioData[index] == "")) {
                            Text("\(metadataTitles[index] + audioData[index])")
                        }
                    }
                    .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                }
            }
            
            UIKitProgressView(value: $currentTime, total: duration)
                //.focusable(true) //potentially lets us set up for scrubbing
                .padding()
            
            HStack {
                Button(action: {
                    seekToZero()
                }) {
                    Image(systemName: "backward.end.fill")
                        .frame(width:50, height:50)
                }
                .background(GeometryReader { geo in
                Color.clear
                    .onAppear {
                        buttonWidth = geo.size.width
                        buttonHeight = geo.size.height
                    }
                })
            
                Button(action: {
                    playPause()
                }) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .frame(width:50, height:50)
                }
                
                Button(action: {
                    loop.toggle()
                    print("loop: ", loop)
                }) {
                    if (loop) {
                        Image(systemName: "repeat.1")
                            .frame(width:50, height:50)
                    } else {
                        Image("repeat.slash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:45, height:45)
                            .blending(color: buttonIsFocused ? Color(.black) : Color(.white))
                    }
                }
                .frame(width: buttonWidth, height: buttonHeight)
                
                /*Button(action: {
                    player.seek(to: CMTime(seconds: duration*0.995, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                }) {
                    Image(systemName: "forward.fill")
                }*/
            }
        }
        .onPlayPauseCommand {
            playPause()
        }
        .onAppear {
            if(callback){
                cementedAudioPath = audioPath
                cementedAudioName = audioName
                duration = 0
                currentTime = 0
                player.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath: cementedAudioPath)))
                player.play()
            }
            print(audioPath)
            print(audioName)
            print(callback)
            
            player.currentItem?.asset.loadValuesAsynchronously(forKeys: ["duration"]) {
                DispatchQueue.main.async {
                    self.duration = player.currentItem?.asset.duration.seconds ?? 0
                }
            }
            player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 10), queue: DispatchQueue.main) { time in
                self.currentTime = time.seconds
            }
            
            if let currentItem = player.currentItem {
                let metadataList = currentItem.asset.metadata
                for metadata in metadataList {
                    if let commonKey = metadata.commonKey?.rawValue, let value = metadata.value {
                        if commonKey == "title" {
                            audioData[0] = value as! String
                            print("0", value)
                        } else if commonKey == "artist" {
                            audioData[1] = value as! String
                            print("1", value)
                        } else if commonKey == "albumName" {
                            audioData[2] = value as! String
                            print("2", value)
                        } else if commonKey == "albumArtist" {
                            audioData[3] = value as! String
                            print("3", value)
                        }  else if commonKey == "BPM" {
                            audioData[4] = value as! String
                            print("4", value)
                        } else if commonKey == "discNumber" {
                            audioData[5] = value as! String
                            print("5", value)
                        } else if commonKey == "Genre" {
                            audioData[6] = value as! String
                            print("6", value)
                        } else if commonKey == "Year" {
                            audioData[7] = value as! String
                            print("7", value)
                        } else if commonKey == "trackNumber" {
                            audioData[8] = value as! String
                            print("8", value)
                        }
                    }
                    if let key = metadata.commonKey?.rawValue, key == "artwork" {
                        audioArtwork = UIImage(data: (metadata.value as? Data)!)
                    }
                }
            }
        }
        .onReceive((player.publisher(for: \.timeControlStatus))) { timeControlStatus in
            isPlaying = timeControlStatus == .playing
            if(!isPlaying && currentTime == duration){
                seekToZero()
                currentTime = 0
                if(loop){
                    player.play()
                }
            }
        }
    }
    
    func seekToZero() {
        player.seek(to: CMTime(seconds: 0, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func playPause() {
        if isPlaying {
            player.pause()
            /*playerNode.pause()
            stopWaveformVisualization()*/
        } else {
            player.play()
            /*playerNode.play()
            startWaveformVisualization()*/
        }
    }
}

extension Double {
    func format() -> String {
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
}