//
//  PlayerNode.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//
import SpriteKit
import GameplayKit

class PlayerNode: SKSpriteNode {
    
    var stateMachine: GKStateMachine!
    var idleTextures: [SKTexture] = []
    var leftTextures: [SKTexture] = []
    var upTextures: [SKTexture] = []
    var rightTextures: [SKTexture] = []
    var downTextures: [SKTexture] = []
    var dashTextures: SKTexture?
 
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        
        loadTextures()
        
        stateMachine = GKStateMachine(states: [
            IdleState(player: self),
            
            DownState(player: self),
            LeftState(player: self),
            RightState(player: self),
            UpState(player: self),
            
            DashState(player: self)
        ])
        
        stateMachine.enter(IdleState.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadTextures() {
        let atlas = SKTextureAtlas(named: "mainCharacter")
        
        idleTextures.append(atlas.textureNamed("idle1"))
        idleTextures.append(atlas.textureNamed("idle2"))
        idleTextures.append(atlas.textureNamed("idle3"))
        
        downTextures.append(atlas.textureNamed("down"))
        
        rightTextures.append(atlas.textureNamed("right"))
        
        leftTextures.append(atlas.textureNamed("left"))
        
    }
    
    func update(deltaTime: TimeInterval) {
        stateMachine.update(deltaTime: deltaTime)
    }
}
