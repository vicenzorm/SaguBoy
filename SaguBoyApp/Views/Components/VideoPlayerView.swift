//
//  VideoPlayerView.swift
//  SaguBoyApp
//
//  Created by Jean Pierre on 01/01/25.
//

import SwiftUI
import AVKit


struct VideoPlayerLayerView: UIViewRepresentable {
    let player: AVPlayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.frame = view.bounds
        
        view.layer.addSublayer(playerLayer)
        
        DispatchQueue.main.async {
            playerLayer.frame = view.bounds
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            layer.player = player
        }
    }
}

@Observable
final class PlayerHolder {
    let player: AVPlayer
    private var looper: AVPlayerLooper?

    init?(resource name: String, ext: String) {
        // TENTE CARREGAR o recurso – se falhar, retorne nil e evite force unwrap
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            print("Vídeo não encontrado: \(name).\(ext)")
            return nil
        }

        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer(items: [item])
        self.player = queue

//        self.looper = AVPlayerLooper(player: queue, templateItem: item)

        self.player.isMuted = true
        self.player.seek(to: .zero)
    }

    func play() { player.play() }
    func pause() { player.pause() }
    func stopAndReset() {
        player.pause()
        player.seek(to: .zero)
    }
}

