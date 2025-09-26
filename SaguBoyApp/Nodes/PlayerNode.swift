//
//  PlayerNode.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//
import SpriteKit
import GameplayKit

class PlayerNode: SKNode {
    
    private let desiredSpriteSize = CGSize(width: 39, height: 70)
    
    private var currentAnimationSprite: SKSpriteNode?
    
    let animationFrameRate = 24.0
    
    var timePerFrame: TimeInterval {
        1.0 / animationFrameRate
    }
    var stateMachine: GKStateMachine!
    var idleTexture: SKTexture?
    var leftTextures: [SKTexture] = []
    var upTextures: [SKTexture] = []
    var rightTextures: [SKTexture] = []
    var downTextures: [SKTexture] = []
    var dashTexture: SKTexture?
 
    override init() {
        super.init()
        
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
    
    func transitionToAnimation(textures: [SKTexture], fadeDuration: TimeInterval = 0.10) {
        guard let firstFrame = textures.first else { return }
        let oldSprite = currentAnimationSprite
        
        let newSprite = SKSpriteNode(texture: firstFrame)
        newSprite.size = desiredSpriteSize
        newSprite.alpha = 0.0
        addChild(newSprite)
        
        let animationAction = SKAction.animate(with: textures, timePerFrame: self.timePerFrame)
        newSprite.run(.repeatForever(animationAction))
        
        newSprite.run(.fadeIn(withDuration: fadeDuration))
        
        if let oldSprite = oldSprite {
            oldSprite.run(.sequence([
                .fadeOut(withDuration: fadeDuration),
                .removeFromParent()
            ]))
        }
        
        self.currentAnimationSprite = newSprite
    }
    
    func transitionToStaticSprite(texture: SKTexture?, fadeDuration: TimeInterval = 0.05) {
        guard let texture = texture else { return }

        let oldSprite = currentAnimationSprite

        let newSprite = SKSpriteNode(texture: texture)
        newSprite.size = desiredSpriteSize
        newSprite.alpha = 0.0
        addChild(newSprite)

        newSprite.run(.fadeIn(withDuration: fadeDuration))

        if let oldSprite = oldSprite {
            oldSprite.run(.sequence([
                .fadeOut(withDuration: fadeDuration),
                .removeFromParent()
            ]))
        }

        self.currentAnimationSprite = newSprite
    }
    
    private func loadTextures() {
        loadUp()
        loadDown()
        loadLeft()
        loadRight()
        loadDash()
        loadIdle()
    }
    
    func update(deltaTime: TimeInterval) {
        stateMachine.update(deltaTime: deltaTime)
    }
    
    func loadDown() {
        let atlas = SKTextureAtlas(named: "maincharacter")
        for i in 1...8 {
            let textureName = String(format: "%04d", i)
            let texture = atlas.textureNamed(textureName)
            texture.filteringMode = .nearest
            downTextures.append(texture)
        }
    }
    
    func loadLeft() {
        let atlas = SKTextureAtlas(named: "maincharacter")
        for i in 1...8 {
            let textureName = String(format: "%04d", i)
            let texture = atlas.textureNamed(textureName)
            texture.filteringMode = .nearest
            leftTextures.append(texture)
        }
    }
    
    func loadRight() {
        let atlas = SKTextureAtlas(named: "maincharacter")
        for i in 1...8 {
            let textureName = String(format: "%04d", i)
            let texture = atlas.textureNamed(textureName)
            texture.filteringMode = .nearest
            rightTextures.append(texture)
        }
    }
    
    func loadUp() {
        let atlas = SKTextureAtlas(named: "maincharacter")
        for i in 1...8 {
            let textureName = String(format: "%04d", i)
            let texture = atlas.textureNamed(textureName)
            texture.filteringMode = .nearest
            upTextures.append(texture)
        }
    }
    
    func loadIdle() {
        let atlas = SKTextureAtlas(named: "maincharacter")
        let textureName = String(format: "%04d", 2)
        idleTexture = atlas.textureNamed(textureName)
        idleTexture?.filteringMode = .nearest
    }
    
    func loadDash() {
        let atlas = SKTextureAtlas(named: "maincharacter")
        let textureName = String(format: "%04d", 10)
        dashTexture = atlas.textureNamed(textureName)
        dashTexture?.filteringMode = .nearest
    }
}
