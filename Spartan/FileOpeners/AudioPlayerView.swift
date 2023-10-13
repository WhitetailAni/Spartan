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
    @State var isFocused = false
    @State var metadataTitles: [String] = [NSLocalizedString("ALBUM", comment: "- Wonder what it'll be like?"), NSLocalizedString("ARTIST", comment: "- A little scary."), NSLocalizedString("ALBUMARTIST", comment: "Welcome to Honex, a division of Honesco"), NSLocalizedString("GENRE", comment: "and a part of the Hexagon Group."), NSLocalizedString("YEAR", comment: "This is it!"), NSLocalizedString("TRACKNUMBER", comment: "Wow."), NSLocalizedString("DISCNUMBER", comment: "Wow."), NSLocalizedString("BPM", comment: "We know that you, as a bee, have worked your whole life")]
    
    @Binding var isPresented: Bool
    
    //i love bad SVG support
    @State var buttonWidth: CGFloat = 0
    @State var buttonHeight: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if(duration == 0 || (audioPath == "" && player.isPlaying)){
                        Text(NSLocalizedString("AUDIO_ERROR", comment: "to get to the point where you can work for your whole life."))
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                            .font(.system(size: 40))
                            .multilineTextAlignment(.center)
                            .padding()
                    } else if(audioData[0] == ""){
                        Text(UserDefaults.settings.bool(forKey: "descriptiveTitles") ? cementedAudioPath + cementedAudioName : cementedAudioName)
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                            .font(.system(size: 40))
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        Text(audioData[0])
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 40)
                            }
                            .font(.system(size: 40))
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
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 30)
                            }
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("\(currentTime.format()) / \(duration.format())")
                            .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                view.scaledFont(name: "BotW Sheikah Regular", size: 30)
                            }
                            .font(.system(size: 30))
                            .multilineTextAlignment(.leading)
                    }
                    Text("")
                    ForEach(1..<audioData.count, id: \.self) { index in
                        if(!(audioData[index] == "")) {
                            Text("\(metadataTitles[index] + audioData[index])")
                                .if(UserDefaults.settings.bool(forKey: "sheikahFontApply")) { view in
                                    view.scaledFont(name: "BotW Sheikah Regular", size: 30)
                                }
                                .font(.system(size: 30))
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
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
                }) {
                    if (loop) {
                        Image(systemName: "repeat.1")
                            .frame(width:50, height:50)
                    } else {
                        Image("repeat.slash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:45, height:45)
                            .blending(color: isFocused ? Color(.black) : Color(.white))
                    }
                }
                .frame(width: buttonWidth, height: buttonHeight)
                /*.modifier(FocusableModifier(onFocusChange: { focused in
                    buttonIsFocused = focused
                }))*/
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
                player.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath: (cementedAudioPath + "/" + cementedAudioName))))
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
                            audioData[0] = value as? String ?? ""
                        } else if commonKey == "artist" {
                            audioData[1] = value as? String ?? ""
                        } else if commonKey == "albumName" {
                            audioData[2] = value as? String ?? ""
                        } else if commonKey == "albumArtist" {
                            audioData[3] = value as? String ?? ""
                        }  else if commonKey == "BPM" {
                            audioData[4] = value as? String ?? ""
                        } else if commonKey == "discNumber" {
                            audioData[5] = value as? String ?? ""
                        } else if commonKey == "Genre" {
                            audioData[6] = value as? String ?? ""
                        } else if commonKey == "Year" {
                            audioData[7] = value as? String ?? ""
                        } else if commonKey == "trackNumber" {
                            audioData[8] = value as? String ?? ""
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
    
    private func updateFocusState() {
        DispatchQueue.main.async {
            let isCurrentlyFocused = UIApplication.shared.windows.first?.isKeyWindow ?? false
            isFocused = isCurrentlyFocused
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

extension AVPlayer {
	var isPlaying: Bool {
		return self.rate != 0 && error == nil
	}
}
