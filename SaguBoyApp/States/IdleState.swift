//
//  IdleState.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//
import SpriteKit
import GameplayKit

class IdleState: PlayerState {
    
    override func didEnter(from previousState: GKState?) {
        let idleAnimation = SKAction.animate(with: player.idleTextures, timePerFrame: player.timePerFrame)
        let loopAnimation = SKAction.repeatForever(idleAnimation)
        player.run(loopAnimation, withKey: "idleAnimation")
    }
    
    override func willExit(to nextState: GKState) {
        player.removeAction(forKey: "idleAnimation")
    }
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let classIs = (stateClass is UpState.Type || stateClass is LeftState.Type || stateClass is DownState.Type || stateClass is DashState.Type || stateClass is RightState.Type)
        return classIs
    } 
    
}
