//
//  Untitled.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 15/09/25.
//

import SpriteKit
import SwiftUI

final class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - App State Management
    private var wasPausedByAppBackground = false
    private var appStateObserver: NSObjectProtocol?

    // MARK: - Callbacks (para SwiftUI reagir)
    var onLivesChanged: ((Int) -> Void)?
    var onGameOver: (() -> Void)?
    var onPointsChanged:((Int) -> Void)?
    var onPowerupChanged: ((Int) -> Void)?

    // MARK: - Player
    private let playerRadius: CGFloat = 30
    private let playerSpeed: CGFloat = 180
    private let playerMinPoints = 0
    private var playerPoints = 0 { didSet { onPointsChanged?(playerPoints) } }
    private var playerLifes = 3 { didSet { onLivesChanged?(playerLifes) } }
    private let playerMaxLifes = 3
    private(set) var player: PlayerNode!
    
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
    private let hitSound = SKAction.playSoundFileNamed("hit.mp3", waitForCompletion: false)
    private let powerUpSound = SKAction.playSoundFileNamed("powerUp.mp3", waitForCompletion: false)
    private let powerUpSpawnSound = SKAction.playSoundFileNamed("powerupspawn.wav", waitForCompletion: false)
    private let WindHitSound = SKAction.playSoundFileNamed("windHit.wav", waitForCompletion: false)
    private let dashSound = SKAction.playSoundFileNamed("dash.mp3", waitForCompletion: false)
    private let invicibilitySound = SKAction.playSoundFileNamed("invicibility.mp3", waitForCompletion: false)
    private let perfectDodgeSound = SKAction.playSoundFileNamed("perfectDodge.mp3", waitForCompletion: false)

    // MARK: - Time
    private var lastUpdateTime: TimeInterval = 0
    private var currentTimeCache: TimeInterval = 0
    
    // MARK: - Propriedades para o sistema de Dash
    private var dashCooldown: TimeInterval = 1.5 // Tempo de recarga do dash
    private var lastDashTime: TimeInterval = 0
    private var isDashing: Bool = false
    private var dashDuration: TimeInterval = 0.5 // Duração do dash
    private var dashSpeedMultiplier: CGFloat = 3.0 // Multiplicador de velocidade durante o dash
    
    // MARK: - Pause Menu
    private var pauseMenu: SKNode?
    private var pauseOptions: [SKLabelNode] = []
    private var optionBackgrounds: [SKShapeNode] = []
    private var selectedPauseIndex = 0
    private var isPausedMenuActive = false
    
    // MARK: - Background GIF
    private var backgroundNode: GIFNode?
    
    // MARK: - Test Variables
    
    #if DEBUG
    var isGameRunningGetter: Bool {
        return isGameRunning
    }
    
    var activeDirectionsGetter: Set<Direction> {
        return activeDirections
    }
    
    var restGameGetter: [String: Int] {
        return ["points": playerMinPoints, "invincibleUntil": Int(invincibleUntil), "lastUpdate": Int(lastUpdateTime), "powerupCharges": powerupCharges]
    }
    
    var pointsGetter: Int { playerPoints }
    
    var buttonAIsPressed: Bool = false
    var buttonBIsPressed: Bool = false
    
    var playerSpeedGetter: Int { Int(currentPlayerSpeed) }
    
    var currentTimeGetter: Int { Int(currentTimeCache) }
    var lastUpdateTimeGetter: Int { Int(lastUpdateTime) }
    
    #endif
    
    // MARK: - Test Functions
    
    #if DEBUG
    
    func _test_performDash(hadEnemyNearby: Bool) {
        performDash(hadEnemyNearby: hadEnemyNearby)
    }
    
    func _test_checkEnemyNearby(radius: CGFloat) -> Bool {
        return checkEnemyNearby(radius: radius)
    }
    
    func _test_setDirection(_ dir: Direction, active: Bool) {
        setDirection(dir, active: active)
    }
    
    func _test_startGame() {
       startGame()
    }
    
    func _test_resetGame() {
       resetGame()
    }
    
    func _test_gameOver() {
       gameOver()
    }
    
    func _test_handleA(pressed: Bool) {
       handleA(pressed: pressed)
    }
    
    func _test_handleB(pressed: Bool) {
        handleB(pressed: pressed)

    }
    
    func _test_spawnEnemy() {
        scheduleSpawns()
    }
    
    
    func _test_spawnWind() {
        scheduleSpawns()
    }
    
    func _test_spawnPowerUp() {
        schedulePowerupSpawns()
    }
    
    func _test_updatePoints(dt: TimeInterval) {
        updatePoints(dt: dt)
    }
    
    
    
    
    #endif

    
    init(size: CGSize, testPlayer: PlayerNode? = nil) {
        super.init(size: size)
        
        if let injectedPlayer = testPlayer {
            self.player = injectedPlayer
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Ciclo de vida
    override func didMove(to view: SKView) {
        
        view.ignoresSiblingOrder = true
        view.isMultipleTouchEnabled = true
        view.showsFPS = true
        view.showsNodeCount = true
        
        print(Bundle.main.bundlePath)

        startGame()
    }
    
    // MARK: - Público (entrada)
//    func setDirection(_ dir: Direction, active: Bool) {
//        if active { activeDirections.insert(dir) } else { activeDirections.remove(dir) }
//    }
//    
    func startGame() {

        // Configura o fundo com GIF
        setupGIFBackground()
        scaleMode = .resizeFill
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        isGameRunning = true
        currentPlayerSpeed = playerSpeed // Inicializa a velocidade
        setupPlayer()
        scheduleSpawns()
        schedulePowerupSpawns()
        
        // Configura observadores do estado do app
        setupAppStateObservers()
        
        AudioManager.shared.startBackgroundMusic()
    }
    
    // MARK: - Estados do App
    private func setupAppStateObservers() {
        // Remove observador anterior se existir
        if let observer = appStateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        
        // Observa quando o app vai para background
        appStateObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.appDidEnterBackground()
        }
        
        // Observa quando o app volta ao foreground
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.appDidBecomeActive()
        }
    }

    private func appDidEnterBackground() {
        // Salva o estado atual
        wasPausedByAppBackground = isPausedMenuActive
        
        // Se o jogo não estava pausado, pausa completamente
        if !isPausedMenuActive && isGameRunning {
            pauseEntireGame()
        }
    }

    private func appDidBecomeActive() {
        // ⚠️ REMOVA as chamadas de restart dos spawns daqui!
        // O controle dos spawns agora fica apenas no handleStart()
        
        // Se foi pausado automaticamente ao entrar em background, mantém pausado
        if wasPausedByAppBackground && !isPausedMenuActive {
            showPauseMenu()
        }
        // Se estava com menu de pausa ativo antes de ir para background, apenas atualiza
        else if wasPausedByAppBackground && isPausedMenuActive {
            // Apenas atualiza a seleção, NÃO reinicia spawns
            updatePauseMenuSelection()
        }
    }

    private func removeAppStateObservers() {
        if let observer = appStateObserver {
            NotificationCenter.default.removeObserver(observer)
            appStateObserver = nil
        }
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    private func pauseEntireGame() {
        isGameRunning = false
        
        // 1. Pausa a cena principal
        self.isPaused = true
        
        // 2. Para todas as ações dos nós
        removeAllActionsFromAllNodes()
        
        // 3. ⚠️ PARA os sistemas de spawn também!
        removeAction(forKey: "spawnLoop")
        removeAction(forKey: "powerupLoop")
        
        // 4. Mostra o menu de pausa
        showPauseMenu()
    }

    private func resumeEntireGame() {
        // 1. Remove menu de pausa
        hidePauseMenu()
        
        // 2. Reativa cena
        self.isPaused = false
        
        // 3. ⚠️ SÓ reinicia os spawns se não existirem ações ativas
        if action(forKey: "spawnLoop") == nil {
            scheduleSpawns()
        }
        if action(forKey: "powerupLoop") == nil {
            schedulePowerupSpawns()
        }
        
        // 4. Reinicia movimentos dos nós existentes
        restartAllMovements()
        
        isGameRunning = true
        wasPausedByAppBackground = false
    }
    
    private func restartAllMovements() {
        // Reinicia movimento dos inimigos
        enumerateChildNodes(withName: "enemy") { node, _ in
            let distance = self.size.height + 120
            let speed: CGFloat = 140
            let duration = TimeInterval(distance / speed)
            
            let move = SKAction.moveBy(x: 0, y: -distance, duration: duration)
            let remove = SKAction.removeFromParent()
            node.run(.sequence([move, remove]))
        }
        
        // Reinicia movimento dos powerups
        enumerateChildNodes(withName: "powerup") { node, _ in
            let distance = self.size.height + 120
            let speed: CGFloat = 100
            let duration = TimeInterval(distance / speed)
            
            node.run(.sequence([.moveBy(x: 0, y: -distance, duration: duration), .removeFromParent()]))
        }
        
        // Reinicia movimento dos ventos
        enumerateChildNodes(withName: "//SKShapeNode") { node, _ in
            // Verifica se é um vento (pela cor ou outras características)
            if let shapeNode = node as? SKShapeNode, shapeNode.fillColor == .blue {
                let distance = self.size.width + 80
                let duration: TimeInterval = 4
                
                // Determina a direção baseada na posição atual
                let shouldMoveLeft = node.position.x > self.size.width / 2
                let move = shouldMoveLeft ?
                    SKAction.moveBy(x: -distance, y: 0, duration: duration) :
                    SKAction.moveBy(x: distance, y: 0, duration: duration)
                
                let remove = SKAction.removeFromParent()
                node.run(SKAction.sequence([move, remove]))
            }
        }
    }
    
    // MARK: - Controle de Ações dos Nodes
    private func removeAllActionsFromAllNodes() {
        enumerateChildNodes(withName: "//*") { node, _ in
            node.removeAllActions() // ✅ Isso SIM para as ações!
        }
    }

    private func pauseAllNodeActions() {
        enumerateChildNodes(withName: "//*") { node, _ in
            node.isPaused = true
        }
    }

    private func resumeAllNodeActions() {
        enumerateChildNodes(withName: "//*") { node, _ in
            node.isPaused = false
        }
    }

    private func pauseAllAnimations() {
        // Pausa especificamente as animações do menu de pausa
        pauseOptions.forEach { $0.isPaused = true }
        optionBackgrounds.forEach { $0.isPaused = true }
    }

    private func restorePauseMenuAnimations() {
        // Restaura as animações do menu de pausa ao estado normal
        updatePauseMenuSelection()
    }
    
    // MARK: - Público (entrada)
    func setDirection(_ dir: Direction, active: Bool) {
        if isPausedMenuActive {
            guard active else { return }
            if dir == .left {
                selectedPauseIndex = max(0, selectedPauseIndex - 1)
                updatePauseMenuSelection()
            } else if dir == .right {
                selectedPauseIndex = min(pauseOptions.count - 1, selectedPauseIndex + 1)
                updatePauseMenuSelection()
            }
        } else {
            // lógica normal do player
            if active { activeDirections.insert(dir) } else { activeDirections.remove(dir) }
        }
    }


    func resetGame() {
        // Para tudo primeiro
        removeAllActions()
        removeAllChildren()
        
        // Recria o fundo
        setupGIFBackground()
        
        isGameRunning = true
        self.isPaused = false
        currentPlayerSpeed = playerSpeed
        isDashing = false

        setupPlayer()
        
        // ⚠️ SÓ agenda spawns se o jogo estiver rodando
        if isGameRunning {
            scheduleSpawns()
            schedulePowerupSpawns()
        }
        
        playerLifes = playerMaxLifes
        playerPoints = playerMinPoints
        invincibleUntil = 0
        lastUpdateTime = 0
        powerupCharges = 0
        
        // Remove qualquer menu de pausa residual
        hidePauseMenu()
        isPausedMenuActive = false
        wasPausedByAppBackground = false
    }
    
    
    func handleA(pressed: Bool) {
        buttonAIsPressed = pressed
        
        guard pressed, powerupCharges > 0 else { return }
        if powerupCharges > 0 {
            run(invicibilitySound)
        }
        powerupCharges = 0
        grantPowerInvincibility()
        
    }
    
    func handleB(pressed: Bool) {
        buttonBIsPressed = pressed
        
        guard pressed else { return }
        
        let currentTime = CACurrentMediaTime()
        // verifica se o dash está disponível (cooldown)
        if currentTime - lastDashTime >= dashCooldown {
            let hadEnemyNearby = checkEnemyNearby(radius: 50) // verifica inimigos próximos
            performDash(hadEnemyNearby: hadEnemyNearby)
            lastDashTime = currentTime
            if SettingsManager.shared.isSoundEnabled {
              run(dashSound)
            } 
        }        
    }
    
    func handleStart(pressed: Bool) {
        guard pressed else { return }
        
        if !isPausedMenuActive {
            // Abre o pause
            pauseEntireGame()
        } else {
            // Confirma seleção
            if selectedPauseIndex == 0 {
                // Continuar - ⚠️ AGORA SÓ AQUI os spawns reiniciam
                resumeEntireGame()
            } else if selectedPauseIndex == 1 {
                // Sair - ⚠️ NÃO reinicia spawns
                hidePauseMenu()
                onGameOver?()
            }
        }
        
        buttonBIsPressed = pressed

    }
    
    /// Verifica se há inimigos próximos do player
    private func checkEnemyNearby(radius: CGFloat) -> Bool {
    var foundEnemy = false
    enumerateChildNodes(withName: "enemy") { node, stop in
        let distance = hypot(node.position.x - self.player.position.x,
                                node.position.y - self.player.position.y)
        if distance <= radius {
            foundEnemy = true
            stop.pointee = true
        }
    }
    return foundEnemy
}
    
    private func performDash(hadEnemyNearby: Bool) {
        // Verificar se o player está se movendo (há direções ativas)
        guard !activeDirections.isEmpty else { return }
        
        isDashing = true
        currentPlayerSpeed = playerSpeed * dashSpeedMultiplier
        
        player.stateMachine.enter(DashState.self)
        
        // Partículas de dash
        if let dashParticles = SKEmitterNode(fileNamed: "DashParticles") {
            dashParticles.position = player.position
            dashParticles.zPosition = -1
            addChild(dashParticles)
            
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
                
                // se havia inimigo próximo E o player não foi atingido, dá pontos bônus
                if hadEnemyNearby && self.playerLifes > 0 {
                    let bonus = 5900
                    self.playerPoints += bonus
                    
                    // Som de desvio perfeito
                    self.run(self.perfectDodgeSound)
                    
                    // Feedback visual
                    let label = SKLabelNode(text: "+\(bonus)!")
                    label.fontSize = 20
                    label.fontColor = .yellow
                    label.position = self.player.position
                    label.zPosition = 1000 // garante que vai ficar em cima
                    self.addChild(label)
                    label.run(SKAction.sequence([
                        SKAction.moveBy(x: 0, y: 30, duration: 0.8),
                        SKAction.fadeOut(withDuration: 0.8),
                        SKAction.removeFromParent()
                    ]))
                }
                
                // Efeito visual de fim de dash
                self.player.run(SKAction.colorize(with: .white, colorBlendFactor: 0, duration: 0.1))
            }
        ]))
        
    }
    
    private func setupGIFBackground() {
        // Remove o fundo anterior se existir
        backgroundNode?.removeFromParent()
        
        // Cria o nó do GIF
        backgroundNode = GIFNode(gifName: "backgroundGIF", size: size)
        backgroundNode?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode?.zPosition = -1000 // Muito atrás de tudo
        
        if let backgroundNode = backgroundNode {
            addChild(backgroundNode)
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        // Atualiza o tamanho do fundo quando a cena mudar de tamanho
        backgroundNode?.size = size
        backgroundNode?.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    private func showPauseMenu() {
        isGameRunning = false
        self.isPaused = true
        
        // Pausa todas as ações existentes
        pauseAllNodeActions()
        
        let menu = SKNode()
        menu.zPosition = 10000
        
        // Fundo semitransparente
        let background = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.5), size: size)
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        menu.addChild(background)
        
        // Label "Paused"
        let titleLabel = SKLabelNode(text: "Paused")
        titleLabel.fontName = "JetBrainsMonoNL-Bold"
        titleLabel.fontSize = 40
        titleLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 80)
        titleLabel.fontColor = .white
        menu.addChild(titleLabel)
        
        // Opções
        let options = ["continue", "exit"]
        pauseOptions = []
        optionBackgrounds = []
        
        let totalWidth = CGFloat(options.count - 1) * 150
        let startX = size.width/2 - totalWidth/2
        let baseY = size.height/2 - 20
        
        for (i, title) in options.enumerated() {
            let xPos = startX + CGFloat(i) * 150
            
            // Retângulo branco
            let rect = SKShapeNode(rectOf: CGSize(width: 100, height: 30), cornerRadius: 2)
            rect.fillColor = .white
            rect.strokeColor = .clear
            rect.position = CGPoint(x: xPos, y: baseY)
            rect.zPosition = -1
            menu.addChild(rect)
            optionBackgrounds.append(rect)
            
            // Label do botão
            let label = SKLabelNode(text: title)
            label.fontName = "JetBrainsMonoNL-Regular"
            label.fontSize = 20
            label.position = CGPoint(x: xPos, y: baseY)
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            pauseOptions.append(label)
            menu.addChild(label)
        }
        
        pauseMenu = menu
        addChild(menu)
        isPausedMenuActive = true
        selectedPauseIndex = 0
        updatePauseMenuSelection()
    }

    private func updatePauseMenuSelection() {
        // Remove todas as animações primeiro para evitar acumulação
        pauseOptions.forEach { $0.removeAllActions() }
        optionBackgrounds.forEach { $0.removeAllActions() }
        
        for (i, label) in pauseOptions.enumerated() {
            let isSelected = (i == selectedPauseIndex)
            
            // Reseta para estado base antes de aplicar animações
            label.removeAllActions()
            optionBackgrounds[i].removeAllActions()
            
            label.setScale(1.0)
            optionBackgrounds[i].setScale(1.0)
            label.position.y = size.height/2 - 20
            optionBackgrounds[i].position.y = size.height/2 - 20
            
            // Atualizar retângulo de fundo
            optionBackgrounds[i].isHidden = !isSelected
            
            if isSelected {
                // Animação mais simples e controlada
                let pulseAction = SKAction.sequence([
                    SKAction.scale(to: 1.1, duration: 0.3),
                    SKAction.scale(to: 1.0, duration: 0.3)
                ])
                
                label.run(SKAction.repeatForever(pulseAction))
                optionBackgrounds[i].run(SKAction.repeatForever(pulseAction))
                
                label.fontColor = .black
                label.fontName = "JetBrainsMonoNL-Bold"
            } else {
                label.fontColor = .white
                label.fontName = "JetBrainsMonoNL-Regular"
            }
        }
    }
    
    private func hidePauseMenu() {
        // Para todas as animações do menu antes de remover
        pauseOptions.forEach { $0.removeAllActions() }
        optionBackgrounds.forEach { $0.removeAllActions() }
        
        pauseMenu?.removeFromParent()
        pauseMenu = nil
        pauseOptions = []
        optionBackgrounds = []
        isPausedMenuActive = false
        wasPausedByAppBackground = false
    }
    
    // MARK: - Setup
    private func setupPlayer() {
        let atlas = SKTextureAtlas(named: "maincharacter")
        let playerTexture = atlas.textureNamed("0002")
        
        let node = PlayerNode()
        let physicsSize = CGSize(width: 35, height: 65)
        node.position = CGPoint(x: size.width * 0.5, y: size.height * 0.2)
        
        node.physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.affectedByGravity = false
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.player
        node.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        node.physicsBody?.collisionBitMask = PhysicsCategory.wind
        
        addChild(node)
        self.player = node
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
                let imageName = "bolaNeve"
                let shape = SKSpriteNode(imageNamed: imageName)
                shape.size = CGSize(width: 18, height: 18)
                shape.position = pos
                shape.physicsBody = SKPhysicsBody(circleOfRadius: size.width * 0.5)
                node = shape
            case .box:
                let shape = TroncoNode()
                shape.position = pos
                shape.size = CGSize(width: 68, height: 18)
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
        wind.name = "wind"
        
        
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
        // NÃO ATUALIZE SE O JOGO ESTIVER PAUSADO
        guard !self.isPaused && isGameRunning else { return }
        
        currentTimeCache = currentTime
        
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = min(currentTime - lastUpdateTime, 1.0/30.0)
        lastUpdateTime = currentTime
        updatePoints(dt: dt)
        player.update(deltaTime: dt)
        
        updatePlayer(dt: dt)
        
        cleanupOffscreen()
    }
    
    private func updatePoints(dt: TimeInterval) {
        guard isGameRunning && !self.isPaused else { return }  // ← Adicione verificação de pausa
        timeSinceLastPoint += dt
        let scoringInterval = 1.0 / pointsPerSecond
        if timeSinceLastPoint >= scoringInterval {

            let pointsToAdd = Int(timeSinceLastPoint / scoringInterval)

            playerPoints += pointsToAdd
            
            timeSinceLastPoint -= Double(pointsToAdd) * scoringInterval
        }
    }

    private func updatePlayer(dt: TimeInterval) {
        // Não atualize o player se o jogo estiver pausado
        guard !self.isPaused && isGameRunning, let p = player else { return }
        var dx: CGFloat = 0, dy: CGFloat = 0
        guard let p = player else { return }
        if activeDirections.contains(.left)      { dx -= 1 }
        if activeDirections.contains(.right)     { dx += 1 }
        if activeDirections.contains(.up)        { dy += 1 }
        if activeDirections.contains(.down)      { dy -= 1 }
        if activeDirections.contains(.upLeft)    { dx -= 1; dy += 1 }
        if activeDirections.contains(.upRight)   { dx += 1; dy += 1 }
        if activeDirections.contains(.downLeft)  { dx -= 1; dy -= 1 }
        if activeDirections.contains(.downRight) { dx += 1; dy -= 1 }

        if dx != 0 && dy != 0 {
            let invSqrt2: CGFloat = 1.0 / sqrt(2.0)
            dx *= invSqrt2
            dy *= invSqrt2
        }
        
        if dy > 0 {
            player.stateMachine.enter(UpState.self)
        } else if dy < 0 {
            player.stateMachine.enter(DownState.self)
        } else if dx > 0 {
            player.stateMachine.enter(RightState.self)
        } else if dx < 0 {
            player.stateMachine.enter(LeftState.self)
        } else {
            // Se não há movimento, entra no estado Idle.
            player.stateMachine.enter(IdleState.self)
        }
        
        
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
        // IGNORA COLISÕES SE O JOGO ESTIVER PAUSADO
        guard !self.isPaused && isGameRunning else { return }
        
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
        
        if SettingsManager.shared.isHapticsEnabled {
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        }
        
        playerLifes = max(0, playerLifes - 1)
        startInvincibilityBlink()
        
        if playerLifes <= 0 {
            gameOver()
        }
        
        if SettingsManager.shared.isSoundEnabled {
            run(hitSound)
        }
    }
    
    private func collectPowerup(_ contact: SKPhysicsContact) {
        let powerNode = (contact.bodyA.categoryBitMask == PhysicsCategory.powerup) ? contact.bodyA.node : contact.bodyB.node
        powerNode?.removeFromParent()
        
        if SettingsManager.shared.isHapticsEnabled {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        
        powerupCharges = 1
        
        let s1 = SKAction.scale(to: 1.1, duration: 0.08)
        let s2 = SKAction.scale(to: 1.0, duration: 0.08)
        
        player.run(.sequence([s1, s2]))
        
        if SettingsManager.shared.isSoundEnabled {
            run(powerUpSound)
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
        
        if SettingsManager.shared.isHapticsEnabled {
            run(WindHitSound)
        }
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
    func gameOver() {
        
        isGameRunning = false
        removeAction(forKey: "spawnLoop")
        removeAction(forKey: "enemyLoop")
        removeAction(forKey: "powerupLoop")
        onGameOver?()
    }
    
    // MARK: - Cleanup
    deinit {
        removeAppStateObservers()
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        removeAppStateObservers()
    }
    
}
