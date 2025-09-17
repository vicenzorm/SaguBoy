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
        let idleAnimation = SKAction.animate(with: player.idleTextures, timePerFrame: 0.5)
        let loopAnimation = SKAction.repeatForever(idleAnimation)
        player.run(loopAnimation, withKey: "idleAnimation")
    }
    //quando precisar de loop, sará necessario nos outros states com loop

    override func willExit(to nextState: GKState) {
        player.removeAction(forKey: "idleAnimation")
    } // remove as animações
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        let classIs = (stateClass is UpState.Type || stateClass is LeftState.Type || stateClass is DownState.Type || stateClass is DashState.Type || stateClass is RightState.Type)
        return classIs
    } // ele pode ir para os seguintes estados
    
    
}
