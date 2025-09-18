//
//  GIFNode.swift
//  SaguBoyApp
//
//  Created by Bernardo Garcia Fensterseifer on 18/09/25.
//


// GIFNode.swift
import SpriteKit

class GIFNode: SKSpriteNode {
    private var textures: [SKTexture] = []
    private var animationSpeed: TimeInterval = 0.1
    
    convenience init(gifName: String, size: CGSize) {
        self.init(texture: nil, color: .clear, size: size)
        loadGIFTextures(gifName: gifName)
        startAnimation()
    }
    
    private func loadGIFTextures(gifName: String) {
        guard let bundleURL = Bundle.main.url(forResource: gifName, withExtension: "gif"),
              let imageData = try? Data(contentsOf: bundleURL),
              let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return
        }
        
        let count = CGImageSourceGetCount(source)
        textures = []
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                let texture = SKTexture(cgImage: cgImage)
                textures.append(texture)
            }
        }
    }
    
    private func startAnimation() {
        guard !textures.isEmpty else { return }
        
        let animation = SKAction.animate(with: textures, timePerFrame: animationSpeed)
        run(SKAction.repeatForever(animation))
    }
}