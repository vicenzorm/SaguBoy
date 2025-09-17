//
//  DownState.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//
import SpriteKit
import GameplayKit

class DownState: PlayerState {
    
    override func didEnter(from previousState: GKState?) {
        let downAnimation = SKAction.animate(with: player.downTextures, timePerFrame: 0.2)
        let loopAnimation = SKAction.repeatForever(downAnimation)
        player.run(loopAnimation, withKey: "downAnimation")
    }
    
    override func willExit(to nextState: GKState) {
        player.removeAction(forKey: "downAnimation")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let classIs = (stateClass is IdleState.Type || stateClass is LeftState.Type || stateClass is UpState.Type || stateClass is DashState.Type || stateClass is RightState.Type)
        return classIs
    }
}
