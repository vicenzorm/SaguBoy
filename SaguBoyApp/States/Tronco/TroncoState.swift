//
//  TroncoState.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 24/09/25.
//

import SpriteKit
import GameplayKit

class TroncoState: TronquinhoState {
    override func didEnter(from previousState: GKState?) {
        let animation = SKAction.animate(with: tronco.troncoTextures, timePerFrame: tronco.timePerFrame)
        let loopAnimation = SKAction.repeatForever(animation)
        tronco.run(loopAnimation)
    }
    
}
