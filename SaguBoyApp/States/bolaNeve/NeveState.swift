//
//  NeveState.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 29/09/25.
//

import SpriteKit
import GameplayKit

class NeveState: BolinhaState {
    override func didEnter(from previousState: GKState?) {
        let animation = SKAction.animate(with: bola.bolaTextures, timePerFrame: bola.timePerFrame)
        let loopAnimation = SKAction.repeatForever(animation)
        bola.run(loopAnimation)
    }
    
}
