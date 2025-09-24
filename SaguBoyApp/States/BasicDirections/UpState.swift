//
//  UpState.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//

import SpriteKit
import GameplayKit

class UpState: PlayerState {
    
    override func didEnter(from previousState: GKState?) {
        player.transitionToAnimation(textures: player.upTextures)
    }
    
    override func willExit(to nextState: GKState) {
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let classIs = (stateClass is IdleState.Type || stateClass is LeftState.Type || stateClass is DownState.Type || stateClass is DashState.Type || stateClass is RightState.Type)
        return classIs
    }
}
