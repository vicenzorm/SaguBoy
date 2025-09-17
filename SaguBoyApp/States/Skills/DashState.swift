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
        if let texture = player.dashTextures {
            player.texture = texture
        }
    }
    
    override func willExit(to nextState: GKState) {
        // nada para os que nao sao loop
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let classIs = (stateClass is IdleState.Type || stateClass is LeftState.Type || stateClass is DownState.Type || stateClass is UpState.Type || stateClass is RightState.Type)
        return classIs
    }
}
