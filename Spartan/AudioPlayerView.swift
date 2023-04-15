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
    @State private var audioData: [String] = Array(repeating: "", count: 69)
    @State private var audioArtwork: UIImage?
    @State var isFocused = false
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if(audioPath == "" && duration == 0){
                        Text("Please select an audio file")
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
                    if(!(audioData[2] == "")){
                        Text("Album: \(audioData[2])")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }
                    if(!(audioData[1] == "")){
                        Text("Artist: \(audioData[1])")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }
                    if(!(audioData[3] == "")){
                        Text("Album Artist: \(audioData[3])")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }
                    Text("")
                    if(!(audioData[6] == "")){
                        Text("Genre: \(audioData[6])")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }
                    if(!(audioData[7] == "")){
                        Text("Year: \(audioData[7])")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }
                    if(!(audioData[8] == "")){
                        Text("Track Number: \(audioData[8])")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }
                    if(!(audioData[5] == "")){
                        Text("Disc Number: \(audioData[5])")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }
                    /*if(!(audioData[4] == "")){
                        Text("BPM: \(audioData[4])")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }*/
                }
            }
            .padding()
            
            UIKitProgressView(value: $currentTime, total: duration)
                .focusable(true) //potentially lets us set up for scrubbing
                .padding()
            
            HStack {
                Button(action: {
                    seekToZero()
                }) {
                    Image(systemName: "backward.end.fill")
                        .frame(width:50, height:50)
                }
            
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
                
                Button(action: {
                    loop.toggle()
                    print("main view: " + String(isFocused))
                }) {
                    if (loop) {
                        Image(systemName: "repeat.1")
                            .frame(width:50, height:50)
                    } else {
                        Image(isFocused ? "repeat.slash.black" : "repeat.slash.white")
                            .resizable()
                            .frame(width:50, height:50)
                    }
                }
                
                /*Button(action: {
                    player.seek(to: CMTime(seconds: duration*0.995, preferredTimescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
                }) {
                    Text("jump to almost end")
                }*/
            }
        }
        .onPlayPauseCommand {
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
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
}

extension Double {
    func format() -> String {
        let minutes = Int(self / 60)
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
