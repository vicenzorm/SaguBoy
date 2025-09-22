//
//  PlayerNode.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//
import SpriteKit
import GameplayKit

class PlayerNode: SKSpriteNode {
    
    let animationFrameRate = 30.0
    
    var timePerFrame: TimeInterval {
        1.0 / animationFrameRate
    }
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
        loadUp()
        loadDown()
        loadIdle()
        loadLeft()
        loadRight()
    }
    
    func update(deltaTime: TimeInterval) {
        stateMachine.update(deltaTime: deltaTime)
    }
    
    func loadIdle() {
        let atlas = SKTextureAtlas(named: "mainCharacter")
        for i in 1...30 {
            idleTextures.append(atlas.textureNamed("idle\(i)"))
        }
    }
    
    func loadDown() {
        let atlas = SKTextureAtlas(named: "mainCharacter")
        for i in 1...30 {
            downTextures.append(atlas.textureNamed("down\(i)"))
        }
    }
    
    func loadLeft() {
        let atlas = SKTextureAtlas(named: "mainCharacter")
        for i in 1...30 {
            leftTextures.append(atlas.textureNamed("left\(i)"))
        }
    }
    
    func loadRight() {
        let atlas = SKTextureAtlas(named: "mainCharacter")
        for i in 1...30 {
            rightTextures.append(atlas.textureNamed("right\(i)"))
        }
    }
    
    func loadUp() {
        let atlas = SKTextureAtlas(named: "mainCharacter")
        for i in 1...30 {
            upTextures.append(atlas.textureNamed("up\(i)"))
        }
    }
}
