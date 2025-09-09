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
    var gameTimer: Timer?
    var enemies: [Enemy] = []
    var player = Player()
    
    func startGame() {
        gameTimer?.invalidate()

        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            self.spawnEnemy()
            self.moveEnemies()
            self.checkCollision()
        }
    }
    
    func spawnEnemy() {
        let randomX = CGFloat.random(in: 50...350) // ✅ Random X position
        let size = CGFloat(30)
        let newEnemy = Enemy(position: CGPoint(x: randomX, y: 0), size: size)

        enemies.append(newEnemy)
    }
    
    func moveEnemies() {
        for index in enemies.indices {
            withAnimation(.linear(duration: 0.1)) {
                enemies[index].position.y += 20 // ✅ Moves downward smoothly
            }
        }
        enemies.removeAll { $0.position.y > 430 }
    }
    
    func checkCollision() {
        for enemy in enemies {
            let distance = sqrt(pow(player.position.x - enemy.position.x, 2) +
                                pow(player.position.y - enemy.position.y, 2))

            if distance < (enemy.size / 2 + 25) { // ✅ If enemy size overlaps player
                gameOver = true
                gameTimer?.invalidate() // ✅ Stop game loop
            }
        }
    }
    
    func resetGame() {
        player.position = CGPoint(x: 200, y: 600)
        enemies.removeAll()
        gameOver = false
        startGame()
    }
}
