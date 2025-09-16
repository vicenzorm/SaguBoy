//
//  Untitled.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 15/09/25.
//

import SpriteKit
import SwiftUI

final class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Callbacks (para SwiftUI reagir)
    var onLivesChanged: ((Int) -> Void)?
    var onGameOver: (() -> Void)?
    var onPointsChanged:((Int) -> Void)?

    // MARK: - Player
    private let playerRadius: CGFloat = 15
    private let playerSpeed: CGFloat = 180
    private let playerMinPoints = 0
    private var playerPoints = 0 { didSet { onPointsChanged?(playerPoints) } }
    private var playerLifes = 3 { didSet { onLivesChanged?(playerLifes) } }
    private let playerMaxLifes = 3
    private var player: SKNode!
    
    
    // MARK: - Points
    private let pointsPerSecond = 10.0
    private var timeSinceLastPoint: TimeInterval = 0
    private var isGameRunning = false

    // MARK: - Inimigos
    private let spawnInterval: TimeInterval = 0.8
    private let enemyMinYToRemove: CGFloat = -60

    // MARK: - Invencibilidade (i-frames)
    private let iFrameDuration: TimeInterval = 1.0
    private var invincibleUntil: TimeInterval = 0
    private var isPlayerInvincible: Bool { currentTimeCache < invincibleUntil }

    // MARK: - Input
    private var activeDirections = Set<Direction>()

    // MARK: - Time
    private var lastUpdateTime: TimeInterval = 0
    private var currentTimeCache: TimeInterval = 0

    // MARK: - Ciclo de vida
    override func didMove(to view: SKView) {
        backgroundColor = .black
        scaleMode = .resizeFill
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        setupPlayer()
        scheduleSpawns()
        
        isGameRunning = true
    }

    // MARK: - Público (entrada)
    func setDirection(_ dir: Direction, active: Bool) {
        if active { activeDirections.insert(dir) } else { activeDirections.remove(dir) }
    }

    func resetGame() {
        removeAllActions()
        removeAllChildren()
        isGameRunning = true

        setupPlayer()
        scheduleSpawns()
        playerLifes = playerMaxLifes
        playerPoints = playerMinPoints
        invincibleUntil = 0
        lastUpdateTime = 0
    }

    // MARK: - Setup
    private func setupPlayer() {
        let node = SKShapeNode(circleOfRadius: playerRadius)
        node.fillColor = .green
        node.strokeColor = .clear
        node.position = CGPoint(x: size.width * 0.5, y: size.height * 0.2)

        node.physicsBody = SKPhysicsBody(circleOfRadius: playerRadius)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.player
        node.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        node.physicsBody?.collisionBitMask = PhysicsCategory.none

        addChild(node)
        player = node
    }

    private func scheduleSpawns() {
        let sequence = SKAction.sequence([
            .run { [weak self] in self?.spawnEnemy() },
            .wait(forDuration: spawnInterval)
        ])
        run(.repeatForever(sequence), withKey: "spawnLoop")
    }

    private func spawnEnemy() {
        let kind: EnemyKind = Bool.random() ? .round : .box
        let size = kind.defaultSize

        let minX = size.width * 0.5
        let maxX = self.size.width - size.width * 0.5
        guard maxX >= minX else { return }
        let x = CGFloat.random(in: minX...maxX)

        let startY = self.size.height + size.height
        let pos = CGPoint(x: x, y: startY)

        let node: SKNode

        if let asset = kind.assetName {
            let sprite = SKSpriteNode(imageNamed: asset)
            sprite.size = size
            sprite.position = pos
            node = sprite

            switch kind {
            case .round:
                sprite.physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.5)
            case .box:
                let rect = CGRect(origin: .zero, size: size)
                let path = CGPath(roundedRect: rect, cornerWidth: kind.cornerRadius, cornerHeight: kind.cornerRadius, transform: nil)
                let body = SKPhysicsBody(polygonFrom: path)
                sprite.physicsBody = body
            }
        } else {
            switch kind {
            case .round:
                let shape = SKShapeNode(circleOfRadius: size.width * 0.5)
                shape.fillColor = .red
                shape.strokeColor = .clear
                shape.position = pos
                shape.physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.5)
                node = shape
            case .box:
                let shape = SKShapeNode(rectOf: size, cornerRadius: kind.cornerRadius)
                shape.fillColor = .orange
                shape.strokeColor = .clear
                shape.position = pos
                let rect = CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
                let path = CGPath(roundedRect: rect, cornerWidth: kind.cornerRadius, cornerHeight: kind.cornerRadius, transform: nil)
                shape.physicsBody = SKPhysicsBody(polygonFrom: path)
                node = shape
            }
        }

        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        node.physicsBody?.contactTestBitMask = PhysicsCategory.player
        node.physicsBody?.collisionBitMask = PhysicsCategory.none
        node.name = "enemy"

        addChild(node)

        let distance = self.size.height + 120
        let speed: CGFloat = 140
        let duration = TimeInterval(distance / speed)

        let move = SKAction.moveBy(x: 0, y: -distance, duration: duration)
        let remove = SKAction.removeFromParent()
        node.run(.sequence([move, remove]))
    }

    // MARK: - Update loop
    override func update(_ currentTime: TimeInterval) {
        currentTimeCache = currentTime

        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = min(currentTime - lastUpdateTime, 1.0/30.0)
        lastUpdateTime = currentTime
        updatePoints(dt: dt)
        updatePlayer(dt: dt)
        cleanupOffscreenEnemies()
    }
    
    private func updatePoints(dt: TimeInterval) {
        guard isGameRunning else { return }
        timeSinceLastPoint += dt
        let scoringInterval = 1.0 / pointsPerSecond
        if timeSinceLastPoint >= scoringInterval {

            let pointsToAdd = Int(timeSinceLastPoint / scoringInterval)

            playerPoints += pointsToAdd
            
            timeSinceLastPoint -= Double(pointsToAdd) * scoringInterval
        }
    }

    private func updatePlayer(dt: TimeInterval) {
        guard let p = player else { return }
        var dx: CGFloat = 0, dy: CGFloat = 0
        if activeDirections.contains(.left)  { dx -= 1 }
        if activeDirections.contains(.right) { dx += 1 }
        if activeDirections.contains(.up)    { dy += 1 }
        if activeDirections.contains(.down)  { dy -= 1 }

        if dx != 0 && dy != 0 {
            let invSqrt2: CGFloat = 1.0 / 1.41421356237
            dx *= invSqrt2; dy *= invSqrt2
        }

        let dist = CGFloat(dt) * playerSpeed
        var pos = p.position
        pos.x += dx * dist
        pos.y += dy * dist

        let r = playerRadius
        pos.x = min(max(r, pos.x), size.width - r)
        pos.y = min(max(r, pos.y), size.height - r)
        p.position = pos
    }

    private func cleanupOffscreenEnemies() {
        enumerateChildNodes(withName: "enemy") { node, _ in
            if node.position.y < self.enemyMinYToRemove { node.removeFromParent() }
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask

        let mask = a | b
        if mask == (PhysicsCategory.player | PhysicsCategory.enemy) {
            handlePlayerHit()
        }
    }

    private func handlePlayerHit() {
        guard !isPlayerInvincible else { return }

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        playerLifes = max(0, playerLifes - 1)
        startInvincibilityBlink()

        if playerLifes <= 0 {
            gameOver()
        }
    }

    private func startInvincibilityBlink() {
        invincibleUntil = currentTimeCache + iFrameDuration
        player.alpha = 0.4
        let restore = SKAction.sequence([
            .wait(forDuration: iFrameDuration),
            .run { [weak self] in self?.player.alpha = 1.0 }
        ])
        run(restore)
    }

    private func gameOver() {
        isGameRunning = false
        removeAction(forKey: "spawnLoop")
        onGameOver?()
        
    }
    
    
}
