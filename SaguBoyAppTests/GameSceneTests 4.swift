//
//  GameSceneTests.swift
//  SaguBoyAppTests
//
//  Created by Jean Pierre on 25/09/25.
//

import Testing

@testable import SaguBoyApp
import SpriteKit

@MainActor
@Suite struct GameSceneTests {
    
    // Garante que o que for testado já tera aparecido no frame da tela
    @MainActor
    func eventually(timeout: TimeInterval = 2.0,
                    poll: TimeInterval = 0.01,
                    _ condition: () -> Bool) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return }
            try await Task.sleep(nanoseconds: UInt64(poll * 1_000_000_000))
        }
        throw NSError(domain: "TestTimeout", code: 1, userInfo: nil)
    }
    
    @Test
    func the_game_is_running() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_startGame()
        
        
        #expect(scene.isGameRunningGetter == true)
        
    }
    
    @Test
    func the_game_is_reset() async throws{
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        let view  = SKView(frame: CGRect(x: 0, y: 0, width: 360, height: 640))
        
        view.presentScene(scene)
        
        scene._test_startGame()
        
        // Espera 5 segundos para o jogo acumular pontos
        try await Task.sleep(nanoseconds: 5_000_000_000)
        
        #expect(scene.pointsGetter > 0)
        
        scene._test_resetGame()
        
        guard let minPoints = scene.restGameGetter["points"] else {return}
        guard let invincible = scene.restGameGetter["invincibleUntil"] else {return}
        guard let lastUpdate = scene.restGameGetter["lastUpdate"] else {return}
        guard let powerup = scene.restGameGetter["powerupCharges"] else {return}
        
        #expect(minPoints == 0)
        #expect(invincible == 0)
        #expect(lastUpdate == 0)
        #expect(powerup == 0)
    }
    
    @Test
    func the_game_over() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_gameOver()
        
        #expect(scene.isGameRunningGetter == false)
        
    }
    @Test
    func set_direction_left() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_setDirection(.left, active: true)
                
        #expect(scene.activeDirectionsGetter.contains(.left))
    }
    
    @Test
    func set_direction_right() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_setDirection(.right, active: true)
                
        #expect(scene.activeDirectionsGetter.contains(.right))
    }
    
    @Test
    func set_direction_up() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_setDirection(.up, active: true)
                
        #expect(scene.activeDirectionsGetter.contains(.up))
    }
    
    @Test
    func set_direction_upLeft() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_setDirection(.upLeft, active: true)
                
        #expect(scene.activeDirectionsGetter.contains(.upLeft))
    }
    
    @Test
    func set_direction_upRight() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_setDirection(.upRight, active: true)
                
        #expect(scene.activeDirectionsGetter.contains(.upRight))
    }
    
    @Test
    func set_direction_down() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_setDirection(.down, active: true)
                
        #expect(scene.activeDirectionsGetter.contains(.down))
    }
    
    @Test
    func set_direction_downLeft() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_setDirection(.downLeft, active: true)
                
        #expect(scene.activeDirectionsGetter.contains(.downLeft))
    }
    
    @Test
    func set_direction_downRight() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        scene._test_setDirection(.downRight, active: true)
                
        #expect(scene.activeDirectionsGetter.contains(.downRight))
    }
    
    @Test
    func remove_direction() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        
        scene._test_setDirection(.left, active: true)
        scene._test_setDirection(.left, active: false)
        scene._test_setDirection(.right, active: true)
        
        #expect(scene.activeDirectionsGetter.contains(.right), "DEBUG: \(scene.activeDirectionsGetter)")
        #expect(!scene.activeDirectionsGetter.contains(.left))
    }
    
    
    
    @Test
    func buttonA_is_pressed() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        
        scene._test_handleA(pressed: true)
        
        #expect(scene.buttonAIsPressed)
        
        
    }
    
    @Test
    func buttonB_is_pressed() {
        let scene = GameScene(size: CGSize(width: 360, height: 640))
        
        scene._test_handleB(pressed: true)
        
        #expect(scene.buttonBIsPressed)
        
        
    }
    
    @Test
    func checkEnemyNearby_detects_enemy() {
        let scene = GameScene(size: .init(width: 200, height: 200))
        let view  = SKView()
        view.presentScene(scene)
        
        let playerPos = CGPoint(x: scene.size.width * 0.5,
                                y: scene.size.height * 0.2)

        let enemy = SKSpriteNode(color: .red, size: .init(width: 10, height: 10))
        enemy.name = "enemy"
        enemy.position = CGPoint(x: playerPos.x + 5, y: playerPos.y + 5) // Posiciona o inimigo perto do player
        scene.addChild(enemy)

        let result = scene._test_checkEnemyNearby(radius: 20)
        #expect(result == true)
    }
    
    @Test
    func checkEnemyNearby_not_detects_enemy() {
        let scene = GameScene(size: .init(width: 200, height: 200))
        let view = SKView()
        view.presentScene(scene)

        scene._test_startGame()
        
        let result = scene._test_checkEnemyNearby(radius: 20)
        
        #expect(result == false)
        
        
    }
    
    @Test
    func checks_player_speed_during_dash() {
        let sceneSize = CGSize(width: 200, height: 200)
        
        let player = PlayerNode()
        player.position = CGPoint(x: sceneSize.width * 0.5, y: sceneSize.height * 0.2)
        player.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.wind
        
        let scene = GameScene(size: sceneSize, testPlayer: player)
        let view  = SKView()
        view.presentScene(scene)
        
        scene._test_startGame()

        scene._test_setDirection(.left, active: true)
        scene._test_performDash(hadEnemyNearby: true)
        
        let speed = scene.playerSpeedGetter

        #expect(speed == 540)
    }
    
    @Test
    func checks_if_spawn_enemy_while_game_is_running() async throws{
        let sceneSize = CGSize(width: 200, height: 200)
        
        let scene = GameScene(size: sceneSize)
        let view  = SKView()
        view.presentScene(scene)
        
        scene._test_startGame()
        
        try await Task.sleep(nanoseconds: 5_000_000_000)

        let childrens = scene.children.filter{$0.name == "enemy"}.count
        
        #expect(childrens != 0)
        
        
    }
    
    @Test
    func checks_if_spawn_wind_while_game_is_running() async throws {
        let sceneSize = CGSize(width: 200, height: 200)
        
        let scene = GameScene(size: sceneSize)
        let view  = SKView()
        view.presentScene(scene)
        
        scene._test_startGame()
        
        try await Task.sleep(nanoseconds: 5_000_000_000)

        let childrens = scene.children.filter{$0.name == "wind"}.count
        
        #expect(childrens != 0)
        
        
    }
    
    @Test @MainActor
    func checks_if_spawn_powerup_while_game_is_running() async throws {
        let sceneSize = CGSize(width: 200, height: 200)
        let scene = GameScene(size: sceneSize)
        let view  = SKView()
        view.presentScene(scene)

        scene._test_startGame()

        try await eventually(timeout: 6.0) {          // timeout maior pq o spawn padrão é mais lento
            scene.childNode(withName: "powerup") != nil
        }

        view.presentScene(nil)
    }
    
    @Test
    func checks_if_update_points_while_game_is_running() async throws {
        let sceneSize = CGSize(width: 200, height: 200)
        
        let scene = GameScene(size: sceneSize)
        let view  = SKView()
        view.presentScene(scene)
        
        scene._test_startGame()
        #expect(scene.pointsGetter == 0)
        scene._test_updatePoints(dt: 0.005)

        #expect(scene.pointsGetter == 5)
    
    }
    
}
