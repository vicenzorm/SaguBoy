//
//  rightState.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//
import SpriteKit
import GameplayKit

class RightState: PlayerState {
    
    override func didEnter(from previousState: GKState?) {
        let rightAnimation = SKAction.animate(with: player.rightTextures, timePerFrame: 0.2)
        let loopAnimation = SKAction.repeatForever(rightAnimation)
        player.run(loopAnimation, withKey: "rightAnimation")
    }
    
    override func willExit(to nextState: GKState) {
        player.removeAction(forKey: "rightAnimation")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let classIs = (stateClass is IdleState.Type || stateClass is LeftState.Type || stateClass is DownState.Type || stateClass is DashState.Type || stateClass is UpState.Type)
        return classIs
    }
}
