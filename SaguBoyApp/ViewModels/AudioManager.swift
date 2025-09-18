//
//  AudioManager.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 18/09/25.
//

import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate {
    
    static let shared = AudioManager()
    
    private var musicPlayer: AVAudioPlayer?
    private var currentTrackIndex: Int = -1
    private var musicPlaylist: [String] = [
        "BackGroundMusic"
    ]
    
    private override init() {
        super.init()
    }
    public func startBackgroundMusic() {
        if musicPlayer?.isPlaying ?? false {
            return
        }
        
        musicPlaylist.shuffle()
        currentTrackIndex = -1
        playBackgroundTrack()
    }
    
    private func playBackgroundTrack() {
        currentTrackIndex += 1
        if currentTrackIndex >= musicPlaylist.count {
            currentTrackIndex = 0
        }
        
        let trackName = musicPlaylist[currentTrackIndex]
        
        playTrack(trackName: trackName)
    }
    
    public func playRUSHTrack() {
        stopMusic()
        playTrack(trackName: "RUSHmusic")
    }
    
    private func playTrack(trackName: String) {
        guard let musicURL = Bundle.main.url(forResource: "Moosic/\(trackName)", withExtension: "mp3") else {
            print("nao foi possivel achar a musica \(trackName)")
            playBackgroundTrack()
            return
        }
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: musicURL)
            musicPlayer?.delegate = self
            musicPlayer?.volume = 0.3
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("deu erro na tocagem de musica: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playBackgroundTrack()
        }
    }
    
    public func stopMusic() {
        musicPlayer?.stop()
    }
}

