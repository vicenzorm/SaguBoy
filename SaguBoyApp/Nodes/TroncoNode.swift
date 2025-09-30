//
//  TroncoNode.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 24/09/25.
//

import SpriteKit
import GameplayKit

class TroncoNode: SKSpriteNode {
    
    private let desiredSpriteSize = CGSize(width: 100, height: 46)
    let animationFrameRate = 12.0
    
    var timePerFrame: TimeInterval {
        1.0 / animationFrameRate
    }
    var stateMachine: GKStateMachine!
    
    var troncoTextures: [SKTexture] = []
    
    init() {
        
        let atlas = SKTextureAtlas(named: "tronco")
        let first = atlas.textureNamed("tronco0001")
        first.filteringMode = .nearest
        super.init(texture: first, color: .clear, size: desiredSpriteSize)
            
        loadTextures()
        
        stateMachine = GKStateMachine(states: [
            TroncoState(tronco: self)
        ])
        
        stateMachine.enter(TroncoState.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func loadTextures() {
        let atlas = SKTextureAtlas(named: "tronco")
        for i in 1...10 {
            let textureName = String(format: "tronco%04d", i)
            troncoTextures.append(atlas.textureNamed(textureName))
        }
    }
}
