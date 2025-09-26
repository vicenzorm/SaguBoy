//
//  leftState.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//
import SpriteKit
import GameplayKit

class LeftState: PlayerState {
    
    override func didEnter(from previousState: GKState?) {
        player.transitionToAnimation(textures: player.leftTextures)
    }
    
    override func willExit(to nextState: GKState) {
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let classIs = (stateClass is IdleState.Type || stateClass is UpState.Type || stateClass is DownState.Type || stateClass is DashState.Type || stateClass is RightState.Type)
        return classIs
    } // ele pode ir para os seguintes estados
    
    
}
