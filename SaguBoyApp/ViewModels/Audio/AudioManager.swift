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
        "backgroundMusic"
    ]
    
    private override init() {
        super.init()
    }
    public func startBackgroundMusic() {
        guard SettingsManager.shared.isSoundEnabled else { return }
        
        if musicPlayer?.isPlaying ?? false {
            return
        }
        
        musicPlaylist.shuffle()
        currentTrackIndex = -1
        playBackgroundTrack()
    }
    
    private func playBackgroundTrack() {
        guard SettingsManager.shared.isSoundEnabled else { return }
        
        currentTrackIndex += 1
        if currentTrackIndex >= musicPlaylist.count {
            currentTrackIndex = 0
        }
        
        let trackName = musicPlaylist[currentTrackIndex]
        
        playTrack(trackName: trackName)
    }
    
    public func playRUSHTrack() {
        guard SettingsManager.shared.isSoundEnabled else { return }
        stopMusic()
        playTrack(trackName: "RUSHmusic")
    }
    
    public func playMENUTrack() {
        guard SettingsManager.shared.isSoundEnabled else { return }
        stopMusic()
        playTrack(trackName: "MENUmusic")
    }
    
    public func playDEFEATTrack() {
        guard SettingsManager.shared.isSoundEnabled else { return }
        stopMusic()
        playTrack(trackName: "DEFEATmusic")
    }
    
    private func playTrack(trackName: String) {
        guard SettingsManager.shared.isSoundEnabled,
              let musicURL = Bundle.main.url(forResource: trackName, withExtension: "mp3") else {
            print("Música desativada ou não foi possível achar a musica \(trackName)")
            return
        }
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: musicURL)
            musicPlayer?.delegate = self
            musicPlayer?.volume = 0.5
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

