//
//  GameViewModel.swift
//  SaguBoyGame
//
//  Created by Enzo Tonatto on 09/09/25.
//

import Foundation
import SwiftUI

@Observable
class GameViewModel: GameViewModelProtocol {
    var gameOver = false
    
    var enemies: [Enemy] = []
    var player = Player()
    
    private var enemySpawnTimer: Timer?
    private var enemyMovementTimer: Timer?
    private var moveTimer: Timer?
    
    var activeDirections = Set<Direction>()
    var playAreaSize: CGSize = .init(width: 390, height: 449)
    
    func startGame() {
        stopGame()
        startEnemySpawnLoop()
        startMoveLoop()
        startEnemyMovement()
    }
    
    func stopGame() {
        enemySpawnTimer?.invalidate()
        moveTimer?.invalidate()
        enemyMovementTimer?.invalidate()
        
        enemySpawnTimer = nil
        moveTimer = nil
        enemyMovementTimer = nil
    }
    
    func startEnemySpawnLoop() {
        enemySpawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0/2.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.spawnEnemy()
        }
    }
    
    func startEnemyMovement() {
        enemyMovementTimer = Timer.scheduledTimer(withTimeInterval: 1.0/10.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.moveEnemies()
        }
    }
    
    func startMoveLoop() {
        moveTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.updatePlayerPosition()
            self?.checkCollision()
        }
    }
    
    func spawnEnemy() {
        let size: CGFloat = 30
        let minX = size / 2
        let maxX = max(minX, playAreaSize.width - size / 2)
        let randomX = CGFloat.random(in: minX...maxX)
        let newEnemy = Enemy(position: CGPoint(x: randomX, y: 0), size: size)
        
        enemies.append(newEnemy)
    }
    
    func moveEnemies() {
        for index in enemies.indices {
            withAnimation(.linear(duration: 0.1)) {
                enemies[index].position.y += 20
            }
        }
        enemies.removeAll { $0.position.y - ($0.size/2) > playAreaSize.height - 25}
    }
    
    func checkCollision() {
        for enemy in enemies {
            let dx = player.position.x - enemy.position.x
            let dy = player.position.y - enemy.position.y
            let distance = sqrt(dx*dx + dy*dy)
            if distance < (enemy.size/2 + player.size/2) {
                gameOver = true
                stopGame()
                resetGame()
                break
            }
        }
    }
    
    func resetGame() {
        player.position = CGPoint(x: playAreaSize.width/2, y: playAreaSize.height*0.8)
        enemies.removeAll()
        gameOver = false
        startGame()
    }
    
    func setDirection(_ dir: Direction, active: Bool) {
        if active { activeDirections.insert(dir) } else { activeDirections.remove(dir) }
    }
    
    private func updatePlayerPosition() {
        guard !activeDirections.isEmpty else { return }
        var dx: CGFloat = 0
        var dy: CGFloat = 0
        if activeDirections.contains(.left) {
            dx -= player.speed
        } else if activeDirections.contains(.right) {
            dx += player.speed
        } else if activeDirections.contains(.up) {
            dy -= player.speed
        } else if activeDirections.contains(.down) {
            dy += player.speed
        }
        
        // Normalize diagonal speed
        if dx != 0 && dy != 0 {
            let invSqrt2: CGFloat = 1.0 / 1.41421356237
            dx *= invSqrt2; dy *= invSqrt2
        }
        
        var p = player.position
        p.x += dx
        p.y += dy
        
        // Clamp to play area
        let r = player.size/2
        p.x = min(max(r, p.x), max(r, playAreaSize.width - r))
        p.y = min(max(r, p.y), max(r, playAreaSize.height - r))
        player.position = p
    }
}
