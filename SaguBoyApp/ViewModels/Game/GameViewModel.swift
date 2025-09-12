// GameViewModel.swift — toda a lógica movida para a ViewModel
import Foundation
import SwiftUI

@Observable
class GameViewModel: GameViewModelProtocol {
    var gameOver = false
    var enemies: [Enemy] = []
    var player = Player()
    var activeDirections = Set<Direction>()
    var playAreaSize: CGSize = .init(width: 390, height: 449)
    
    private var gameTimer: Timer?
    private var lastUpdate: CFTimeInterval = CACurrentMediaTime()
    private var accSpawn: CFTimeInterval = 0
    private var accEnemyStep: CFTimeInterval = 0
    
    private let tick: TimeInterval = 1.0 / 60.0
    private let spawnInterval: TimeInterval = 0.8
    private let enemyMoveInterval: TimeInterval = 0.1
    private let enemyStepDistance: CGFloat = 20
    private let iFrameDuration: TimeInterval = 1.0
    
    private var invincibleUntil: CFTimeInterval = 0
    private var isPlayerInvincible: Bool { CACurrentMediaTime() < invincibleUntil }
    
    func startGame() {
        stopGame()
        gameOver = false
        lastUpdate = CACurrentMediaTime()
        gameTimer = Timer.scheduledTimer(withTimeInterval: tick, repeats: true) { [weak self] _ in
            self?.gameLoop()
        }
    }
    
    func stopGame() {
        gameTimer?.invalidate(); gameTimer = nil
    }
    
    private func gameLoop() {
        guard !gameOver else { return }
        
        let now = CACurrentMediaTime()
        var dt = now - lastUpdate
        lastUpdate = now
        if dt > 0.25 { dt = 0.25 }
        
        updatePlayerPosition(dt: dt)
        
        accSpawn += dt
        if accSpawn >= spawnInterval {
            let spawns = Int(accSpawn / spawnInterval)
            for _ in 0..<spawns { spawnEnemy() }
            accSpawn -= spawnInterval * Double(spawns)
        }
        
        accEnemyStep += dt
        if accEnemyStep >= enemyMoveInterval {
            let steps = Int(accEnemyStep / enemyMoveInterval)
            moveEnemies(steps: steps)
            accEnemyStep -= enemyMoveInterval * Double(steps)
        }
        
        checkCollision()
    }
    
    private func spawnEnemy() {
        let size: CGFloat = 30
        let minX = size / 2
        let maxX = max(minX, playAreaSize.width - size / 2)
        let randomX = CGFloat.random(in: minX...maxX)
        enemies.append(Enemy(position: CGPoint(x: randomX, y: 0), size: size))
    }
    
    private func moveEnemies(steps: Int) {
        guard steps > 0 else { return }
        let totalDistance = CGFloat(steps) * enemyStepDistance
        let totalDuration = enemyMoveInterval * Double(steps)
        withAnimation(.linear(duration: totalDuration)) {
            for idx in enemies.indices {
                enemies[idx].position.y += totalDistance
            }
        }
        enemies.removeAll { $0.position.y - ($0.size * 0.5) > playAreaSize.height - 25 }
    }
    
    private func checkCollision() {
        guard !isPlayerInvincible, !gameOver else { return }
        let pr = player.size * 0.5
        for e in enemies {
            let er = e.size * 0.5
            let dx = player.position.x - e.position.x
            let dy = player.position.y - e.position.y
            let r = pr + er
            if (dx*dx + dy*dy) < (r*r) {
                vibrate(with: .heavy)
                applyDamage()
                break
            }
        }
    }
    
    private func applyDamage() {
        guard player.lifes > 0 else { return }
        player.lifes = max(0, player.lifes - 1)
        invincibleUntil = CACurrentMediaTime() + iFrameDuration
        if player.lifes <= 0 { triggerGameOver() }
    }
    
    private func triggerGameOver() {
        gameOver = true
        stopGame()
    }
    
    func resetGame() {
        stopGame()
        enemies.removeAll()
        player.lifes = player.maxLifes
        invincibleUntil = 0
        player.position = CGPoint(x: playAreaSize.width/2, y: playAreaSize.height*0.8)
        gameOver = false
        accSpawn = 0
        accEnemyStep = 0
        startGame()
    }
    
    func setDirection(_ dir: Direction, active: Bool) {
        if active {
            vibrate(with: .light)
            activeDirections.insert(dir)
        } else {
            activeDirections.remove(dir)
        }
    }
    
    private func updatePlayerPosition(dt: CFTimeInterval) {
        guard !activeDirections.isEmpty else { return }
        var dx: CGFloat = 0, dy: CGFloat = 0
        if activeDirections.contains(.left)  { dx -= 1 }
        else if activeDirections.contains(.right) { dx += 1 }
        else if activeDirections.contains(.up)    { dy -= 1 }
        else if activeDirections.contains(.down)  { dy += 1 }
        
        if dx != 0 && dy != 0 {
            let invSqrt2: CGFloat = 1.0 / 1.41421356237
            dx *= invSqrt2; dy *= invSqrt2
        }
        
        let dist = CGFloat(dt) * player.speed
        var p = player.position
        p.x += dx * dist
        p.y += dy * dist
        
        let r = player.size * 0.5
        p.x = min(max(r, p.x), max(r, playAreaSize.width - r))
        p.y = min(max(r, p.y), max(r, playAreaSize.height - r))
        player.position = p
    }
    
    func handleA(_ pressed: Bool) {
        if pressed {
            vibrate(with: .medium)
            /* ação A */
        }
    }
    func handleB(_ pressed: Bool) {
        if pressed {
            vibrate(with: .medium)
            /* ação B */
            }
    }
    func handleStart(_ pressed: Bool) {
        if pressed {
            vibrate(with: .heavy)
            if gameOver { resetGame() } else { startGame() }
        }
    }
}
