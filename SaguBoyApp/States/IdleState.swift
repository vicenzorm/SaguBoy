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
        // Mude para usar animação em loop
        player.transitionToAnimation(textures: player.idleTextures)
    }
    
    override func willExit(to nextState: GKState) {
        // Para a animação quando sair deste estado
        player.currentAnimationSprite?.removeAction(forKey: "currentAnimation")
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let classIs = (stateClass is DashState.Type || stateClass is LeftState.Type || stateClass is DownState.Type || stateClass is UpState.Type || stateClass is RightState.Type)
        return classIs
    }
}

