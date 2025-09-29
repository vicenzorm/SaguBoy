//
//  BolaNode.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 29/09/25.
//

import SpriteKit
import GameplayKit

class BolaNode: SKSpriteNode {
    
    private let desiredSpriteSize = CGSize(width: 35, height: 35)
    let animationFrameRate = 12.0
    
    var timePerFrame: TimeInterval {
        1.0 / animationFrameRate
    }
    var stateMachine: GKStateMachine!
    
    var bolaTextures: [SKTexture] = []
    
    init() {
        
        let atlas = SKTextureAtlas(named: "bolaNeve")
        let first = atlas.textureNamed("bola0001")
        first.filteringMode = .nearest
        super.init(texture: first, color: .clear, size: desiredSpriteSize)
            
        loadTextures()
        
        stateMachine = GKStateMachine(states: [
            NeveState(bola: self)
        ])
        
        stateMachine.enter(TroncoState.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func loadTextures() {
        let atlas = SKTextureAtlas(named: "bolaNeve")
        for i in 1...10 {
            let textureName = String(format: "bola%04d", i)
            bolaTextures.append(atlas.textureNamed(textureName))
        }
    }
}
