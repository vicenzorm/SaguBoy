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
    
    private var isMuted: Bool = false // 🔑 flag de mute
    
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
        playTrack(trackName: "menuTheme")
    }
    
    public func playGAMETrack() {
        guard SettingsManager.shared.isSoundEnabled else { return }
        stopMusic()
        playTrack(trackName: "backgroundMusic")
    }
    
    public func playDEFEATTrack() {
        guard SettingsManager.shared.isSoundEnabled else { return }
        stopMusic()
        playTrackOnce(trackName: "gameOverSound")
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
            musicPlayer?.volume = isMuted ? 0.0 : 0.5
            musicPlayer?.numberOfLoops = -1 // 🔁 loop infinito
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("deu erro na tocagem de musica: \(error.localizedDescription)")
        }
    }

    
    private func playTrackOnce(trackName: String) {
        guard SettingsManager.shared.isSoundEnabled,
              let musicURL = Bundle.main.url(forResource: trackName, withExtension: "mp3") else {
            print("Música desativada ou não foi possível achar a música \(trackName)")
            return
        }
        do {
            musicPlayer = try AVAudioPlayer(contentsOf: musicURL)
            musicPlayer?.delegate = nil
            musicPlayer?.volume = isMuted ? 0.0 : 0.5 // 🔑 respeita mute
            musicPlayer?.numberOfLoops = 0
            musicPlayer?.prepareToPlay()
            musicPlayer?.play()
        } catch {
            print("Erro ao tocar música uma vez: \(error.localizedDescription)")
        }
    }
    
    // 🔊 Controle de volume com persistência
    public func muteMusic() {
        isMuted = true
        musicPlayer?.volume = 0.0
    }
    
    public func unmuteMusic() {
        isMuted = false
        musicPlayer?.volume = 0.5
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            // só continua playlist se estivermos rodando a lista "shuffle"
            if musicPlaylist.count > 1 {
                playBackgroundTrack()
            }
        }
    }

    
    public func stopMusic() {
        musicPlayer?.stop()
    }
}
