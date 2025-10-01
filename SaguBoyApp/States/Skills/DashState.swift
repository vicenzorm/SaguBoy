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
        // Para dash, pode manter estático ou criar animação especial
        if let dashTexture = player.dashTexture {
            player.transitionToStaticSprite(texture: dashTexture)
        }
    }
    
    override func willExit(to nextState: GKState) {
        // Não precisa remover ações se estiver usando static sprite
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass != type(of: self)
    }
}
