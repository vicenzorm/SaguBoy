//
//  GameViewModelProtocol.swift
//  SaguBoyGame
//
//  Created by Enzo Tonatto on 09/09/25.
//

import Foundation

protocol GameViewModelProtocol {
    var gameOver: Bool { get set }
    var enemies: [Enemy] { get }
    
    func startGame()
    func spawnEnemy()
    func moveEnemies()
    func checkCollision()
    func resetGame()
    
}
