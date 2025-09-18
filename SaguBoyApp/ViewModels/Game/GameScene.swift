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
    var onPowerupChanged: ((Int) -> Void)?

    // MARK: - Player
    private let playerRadius: CGFloat = 15
    private let playerSpeed: CGFloat = 180
    private let playerMinPoints = 0
    private var playerPoints = 0 { didSet { onPointsChanged?(playerPoints) } }
    private var playerLifes = 3 { didSet { onLivesChanged?(playerLifes) } }
    private let playerMaxLifes = 3
    private var player: PlayerNode!
    
    // Variável para controlar a velocidade atual (permite modificação)
    private var currentPlayerSpeed: CGFloat = 180
        
    // MARK: - Points
    private let pointsPerSecond = 1000.0
    private var timeSinceLastPoint: TimeInterval = 0
    private var isGameRunning = false

    // MARK: - Inimigos
    private let spawnIntervalEnemies: TimeInterval = 0.8
    private let spawnIntervalWind: TimeInterval = 1.5
    private let enemyMinYToRemove: CGFloat = -60
    
    // MARK: - Power-up
    private let powerupDuration: TimeInterval = 2.0
    private let powerupSpawnInterval: TimeInterval = 4.0
    private var powerupCharges: Int = 0 { didSet { onPowerupChanged?(powerupCharges) } }
    
    // MARK: - Invencibilidade (i-frames)
    private let iFrameDuration: TimeInterval = 1.0
    private var invincibleUntil: TimeInterval = 0
    private var isPlayerInvincible: Bool { currentTimeCache < invincibleUntil }
    
    // MARK: - Input
    private var activeDirections = Set<Direction>()
    
    // MARK: - Sounds
    private let hitSound = SKAction.playSoundFileNamed("hit.wav", waitForCompletion: false)
    private let powerUpSound = SKAction.playSoundFileNamed("powerup.wav", waitForCompletion: false)
    private let powerUpSpawnSound = SKAction.playSoundFileNamed("powerupspawn.wav", waitForCompletion: false)
    private let WindHitSound = SKAction.playSoundFileNamed("windHit.wav", waitForCompletion: false)

    // MARK: - Time
    private var lastUpdateTime: TimeInterval = 0
    private var currentTimeCache: TimeInterval = 0
    
    // MARK: - Propriedades para o sistema de Dash
    private var dashCooldown: TimeInterval = 1.5 // Tempo de recarga do dash
    private var lastDashTime: TimeInterval = 0
    private var isDashing: Bool = false
    private var dashDuration: TimeInterval = 0.2 // Duração do dash
    private var dashSpeedMultiplier: CGFloat = 3.0 // Multiplicador de velocidade durante o dash
    
    // MARK: - Ciclo de vida
    override func didMove(to view: SKView) {
        print(Bundle.main.bundlePath)
        backgroundColor = .black
        scaleMode = .resizeFill
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        isGameRunning = true
        currentPlayerSpeed = playerSpeed // Inicializa a velocidade
        setupPlayer()
        scheduleSpawns()
        schedulePowerupSpawns()
        AudioManager.shared.startBackgroundMusic()
    }
    
    // MARK: - Público (entrada)
    func setDirection(_ dir: Direction, active: Bool) {
        if active { activeDirections.insert(dir) } else { activeDirections.remove(dir) }
    }
    
    func resetGame() {
        removeAllActions()
        removeAllChildren()
        isGameRunning = true
        currentPlayerSpeed = playerSpeed // Reseta a velocidade
        isDashing = false // Reseta o estado de dash

        setupPlayer()
        scheduleSpawns()
        playerLifes = playerMaxLifes
        playerPoints = playerMinPoints
        invincibleUntil = 0
        lastUpdateTime = 0
        powerupCharges = 0
    }
    
    func handleA(pressed: Bool) {
        guard pressed, powerupCharges > 0 else { return }
        powerupCharges = 0
        grantPowerInvincibility()
    }
    
    func handleB(pressed: Bool) {
        guard pressed else { return }
        
        let currentTime = CACurrentMediaTime()
        // Verificar se o dash está disponível (cooldown)
        if currentTime - lastDashTime >= dashCooldown {
            performDash()
            lastDashTime = currentTime
        }
    }
    
    private func performDash() {
        // Verificar se o player está se movendo (há direções ativas)
        guard !activeDirections.isEmpty else { return }
        
        isDashing = true
        
        // Aplicar o boost de velocidade
        currentPlayerSpeed = playerSpeed * dashSpeedMultiplier
        
        // Efeito visual durante o dash
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .cyan, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 0.1)
        ])
        player.run(flashAction)
        
        // Efeito de partículas durante o dash (opcional - se você tiver o arquivo)
        if let dashParticles = SKEmitterNode(fileNamed: "DashParticles") {
            dashParticles.position = player.position
            dashParticles.zPosition = -1
            addChild(dashParticles)
            
            // Remover partículas após um tempo
            dashParticles.run(SKAction.sequence([
                SKAction.wait(forDuration: dashDuration),
                SKAction.removeFromParent()
            ]))
        }
        
        // Restaurar velocidade normal após o dash
        run(SKAction.sequence([
            SKAction.wait(forDuration: dashDuration),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.currentPlayerSpeed = self.playerSpeed
                self.isDashing = false
                
                // Efeito visual de fim de dash
                self.player.run(SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 0.1))
            }
        ]))
    }
    
    
    // MARK: - Setup
    private func setupPlayer() {
        let atlas = SKTextureAtlas(named: "mainCharacter")
        let playerTexture = atlas.textureNamed("idle1")
        
        let node = PlayerNode(texture: playerTexture, color: .white, size: CGSize(width: 30, height: 30))
        
        node.position = CGPoint(x: size.width * 0.5, y: size.height * 0.2)
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: playerRadius)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.player
        node.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        node.physicsBody?.collisionBitMask = PhysicsCategory.wind
        
        addChild(node)
        player = node
    }
    
    private func scheduleSpawns() {
        let sequenceEnemy = SKAction.sequence([
            .run { [weak self] in
                self?.spawnEnemy()
            },
            .wait(forDuration: spawnIntervalEnemies)
        ])

        let sequenceWind = SKAction.sequence([
            .run { [weak self] in
                self?.spawnWind()
            },
            .wait(forDuration: spawnIntervalWind)
        ])
        
        let groupSpawn = SKAction.group([sequenceEnemy, sequenceWind])
        
        run(.repeatForever(groupSpawn), withKey: "spawnLoop")
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
    
    private func spawnWind() {
        guard let view = view else { return }
        
        var wind: SKShapeNode!
        let frame = CGSize(width: 10, height: 100)
        wind = SKShapeNode(rectOf: frame)
        wind.fillColor = .blue
        wind.strokeColor = .clear
        
        let safeArea = CGFloat(view.safeAreaInsets.top + 100)
        
        
        
        // Gere o vento dentro da SafeArea (Entre states do jogador e os controles da metade da tela)
        let randomY = CGFloat.random(in: 50...self.size.height - safeArea)
        
        let randomX_rigth = CGFloat(self.size.width + 40)
        let randomX_left = CGFloat(0)
        
        guard let randomX = [randomX_left, randomX_rigth].randomElement() else { return }
        
        wind.position = CGPoint(x: randomX, y: randomY)
        print("RandomX -> ",randomX)
        
        // Corpo físico
        
        wind.physicsBody = SKPhysicsBody(rectangleOf: frame)
        wind.physicsBody?.isDynamic = true
        wind.physicsBody?.allowsRotation = false
        wind.physicsBody?.categoryBitMask = PhysicsCategory.wind
        wind.physicsBody?.contactTestBitMask = PhysicsCategory.player
        wind.physicsBody?.collisionBitMask = PhysicsCategory.player
        
        
        addChild(wind)
        
        // Move o vento de forma aleatória (Para direita ou esquerda)
        let move = (randomX == randomX_rigth) ? SKAction.moveBy(x: -self.size.width - 80, y: 0, duration: 4)
        : SKAction.moveBy(x: self.size.width + 80, y: 0, duration: 4)
        
        
        let remove = SKAction.removeFromParent()
        wind.run(SKAction.sequence([move, remove]))
        
    }

    
    private func schedulePowerupSpawns() {
        let seq = SKAction.sequence([
            .wait(forDuration: powerupSpawnInterval),
            .run { [weak self] in self?.spawnPowerup() }
        ])
        run(.repeatForever(seq), withKey: "powerupLoop")
    }
    
    private func spawnPowerup() {
        guard powerupCharges == 0, childNode(withName: "powerup") == nil else { return }
        
        let radius: CGFloat = 7
        let minX = radius
        let maxX = size.width - radius
        guard maxX >= minX else { return }
        let x = CGFloat.random(in: minX...maxX)
        
        let dot = SKShapeNode(circleOfRadius: radius)
        dot.fillColor = .cyan
        dot.strokeColor = .clear
        dot.position = CGPoint(x: x, y: size.height + radius * 2)
        dot.name = "powerup"
        
        dot.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        dot.physicsBody?.isDynamic = true
        dot.physicsBody?.affectedByGravity = false
        dot.physicsBody?.allowsRotation = false
        dot.physicsBody?.categoryBitMask = PhysicsCategory.powerup
        dot.physicsBody?.contactTestBitMask = PhysicsCategory.player
        dot.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        addChild(dot)
        
        let distance = self.size.height + 120
        let speed: CGFloat = 100
        let duration = TimeInterval(distance / speed)
        dot.run(.sequence([.moveBy(x: 0, y: -distance, duration: duration), .removeFromParent()]))
        run(powerUpSpawnSound)
    }
    
    // MARK: - Update loop
    override func update(_ currentTime: TimeInterval) {
        currentTimeCache = currentTime
        
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = min(currentTime - lastUpdateTime, 1.0/30.0)
        lastUpdateTime = currentTime
        updatePoints(dt: dt)
        
        updatePlayer(dt: dt)
        
        player.update(deltaTime: dt)
        cleanupOffscreen()
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
        if activeDirections.contains(.left)      { dx -= 1 }
        if activeDirections.contains(.right)     { dx += 1 }
        if activeDirections.contains(.up)        { dy += 1 }
        if activeDirections.contains(.down)      { dy -= 1 }
        if activeDirections.contains(.upLeft)    { dx -= 1; dy += 1 }
        if activeDirections.contains(.upRight)   { dx += 1; dy += 1 }
        if activeDirections.contains(.downLeft)  { dx -= 1; dy -= 1 }
        if activeDirections.contains(.downRight) { dx += 1; dy -= 1 }

        // Normalizar diagonal (senão anda mais rápido na diagonal)
        if dx != 0 && dy != 0 {
            let invSqrt2: CGFloat = 1.0 / 1.41421356237
            dx *= invSqrt2; dy *= invSqrt2
            dx *= invSqrt2
            dy *= invSqrt2
        }
        
        // ESTADOS
        if dy > 0 {
            player.stateMachine.enter(IdleState.self)
        } else if dy < 0 {
            player.stateMachine.enter(DownState.self)
        } else if dx > 0 {
            player.stateMachine.enter(RightState.self)
        } else if dx < 0 {
            player.stateMachine.enter(LeftState.self)
        } else {
            player.stateMachine.enter(IdleState.self)
        }
        
        // Usar currentPlayerSpeed em vez de playerSpeed (constante)
        let dist = CGFloat(dt) * currentPlayerSpeed
        var pos = p.position
        pos.x += dx * dist
        pos.y += dy * dist
        
        let r = playerRadius
        pos.x = min(max(r, pos.x), size.width - r)
        pos.y = min(max(r, pos.y), size.height - r)
        p.position = pos
    }
    
    private func cleanupOffscreen() {
        enumerateChildNodes(withName: "enemy") { node, _ in
            if node.position.y < -60 { node.removeFromParent() }
        }
        enumerateChildNodes(withName: "powerup") { node, _ in
            if node.position.y < -20 { node.removeFromParent() }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch mask {
            
        case PhysicsCategory.player | PhysicsCategory.enemy:
            handlePlayerHit()
            
        case PhysicsCategory.player | PhysicsCategory.powerup:
            collectPowerup(contact)
            
        case PhysicsCategory.player | PhysicsCategory.wind:
            handleWindHit(contact)
            
        default:
            break
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
        run(hitSound)
    }
    
    private func collectPowerup(_ contact: SKPhysicsContact) {
        let powerNode = (contact.bodyA.categoryBitMask == PhysicsCategory.powerup) ? contact.bodyA.node : contact.bodyB.node
        powerNode?.removeFromParent()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        powerupCharges = 1
        
        let s1 = SKAction.scale(to: 1.1, duration: 0.08)
        let s2 = SKAction.scale(to: 1.0, duration: 0.08)
        
        player.run(.sequence([s1, s2]))
        run(powerUpSound)
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
    
    private func grantPowerInvincibility() {
        invincibleUntil = max(invincibleUntil, currentTimeCache) + powerupDuration
        startShieldEffect(for: powerupDuration)
    }
    
    private func startShieldEffect(for duration: TimeInterval) {
        player.childNode(withName: "shield")?.removeFromParent()
        
        player.alpha = 0.4
        let restore = SKAction.sequence([
            .wait(forDuration: iFrameDuration),
            .run { [weak self] in self?.player.alpha = 1.0 }
        ])
        run(restore)
    }
    
    private func handleWindHit(_ contact: SKPhysicsContact) {
            
        guard let wind = (contact.bodyA.categoryBitMask == PhysicsCategory.wind) ? contact.bodyA.node : contact.bodyB.node else { return }
        
        let wait = SKAction.wait(forDuration: 1.25)
        
        let disablePhysics = SKAction.run { [weak wind] in
            wind?.physicsBody = nil
        }
        
        wind.run(SKAction.sequence([wait, disablePhysics]))
        run(WindHitSound)
    }
    
    private func disableWindPhysicBody(_ contact: SKPhysicsContact) {
        
        guard let windNode = (contact.bodyA.categoryBitMask == PhysicsCategory.wind) ? contact.bodyA.node : contact.bodyB.node else { return }
        
        guard let body = windNode.physicsBody else {return}
        
        body.categoryBitMask = PhysicsCategory.none
        body.contactTestBitMask = 0
        body.collisionBitMask = 0
        windNode.physicsBody = nil
     
    }
    // MARK: - Game Over
    private func gameOver() {
        
        isGameRunning = false
        removeAction(forKey: "spawnLoop")
        removeAction(forKey: "enemyLoop")
        removeAction(forKey: "powerupLoop")
        onGameOver?()
    }
    
    
}
