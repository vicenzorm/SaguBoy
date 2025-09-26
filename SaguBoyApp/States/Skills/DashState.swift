//
//  DashState.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//
import SpriteKit
import GameplayKit

class DashState: PlayerState {
    
    override func didEnter(from previousState: GKState?) {
        player.transitionToStaticSprite(texture: player.dashTexture)
    }
    
    override func willExit(to nextState: GKState) {
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let classIs = (stateClass is IdleState.Type || stateClass is LeftState.Type || stateClass is DownState.Type || stateClass is UpState.Type || stateClass is RightState.Type)
        return classIs
    }
}
