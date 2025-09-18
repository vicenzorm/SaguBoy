//
//  GameView.swift
//  POC-GameplayKit
//
//  Created by Vicenzo Másera on 03/09/25.
//
import SwiftUI
import SpriteKit

struct GameView: View {

    @State private var gameCenterViewModel = GameCenterViewModel()

    private func makeScene(size: CGSize) -> GameScene {
        let scene = GameScene()
        scene.size = size
        scene.scaleMode = .resizeFill

        scene.onLivesChanged = { lives in
            self.lives = lives
        }
        scene.onGameOver = {
            Task { await gameCenterViewModel.submitScore(score: self.points, leaderboardID: "mainHighScore") }
            self.isGameOver = true
        }
        scene.onPointsChanged = { points in
            self.points = points
        }
        scene.onPowerupChanged = {
            self.powerups = $0
        }
        return scene
    }

    // HUD state
    @State private var points: Int = 0
    @State private var lives: Int = 3
    @State private var powerups: Int = 0
    @State private var isGameOver: Bool = false
    @State private var scene: GameScene = GameScene()

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(.consoleBackground)
                    .frame(width: 380, height: 476)
                    .shadow(radius: 8)

                SpriteView(scene: scene)
                    .frame(width: 364, height: 415)
                    .clipped()
                    .onAppear {
                        // tamanho da cena igual à área útil visível
                        scene = makeScene(size: CGSize(width: 364, height: 415))
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 8)

                // HUD (fica acima do SpriteView)
                HStack(spacing: 8) {
                    Text("Vidas: \(lives)")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.white)
                        .padding(12)
                    Text("Pontos: \(points)")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.white)
                        .padding(12)
                    Text("Power: \(powerups)/1")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.white)
                        .padding(12)
                }
                
                Text("SaguBoy")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.consoleText)
                    .padding(.top, 450)
                    .padding(.leading, 8)
                Text("Color SB")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(.consoleText)
                    .padding(.top, 444)
                    .padding(.leading, 77)
                    

                // Overlay de Game Over cobrindo só a área do jogo
                if isGameOver {
                    VStack(spacing: 12) {
                        Text("GAME OVER")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    }
                    .frame(width: 364, height: 415)
                    .background(Color.black.opacity(0.5))
                    .padding(.top, 8)
                    .padding(.horizontal, 8)
                    .onTapGesture {
                        isGameOver = false
                        lives = 3
                        powerups = 0
                        scene.resetGame()
                    }
                }
            }
            
            Spacer()

            ControllersView(
                onDirection: { dir, pressed in
                    scene.setDirection(dir, active: pressed)
                },
                onA: { pressed in
                    if pressed {
                        scene.handleA(pressed: pressed)
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                },
                onB: { pressed in
                    if pressed {
                        scene.handleB(pressed: pressed) 
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                },
                onStart: { pressed in
                    if pressed {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        if isGameOver {
                            isGameOver = false
                            lives = 3
                            powerups = 0
                            scene.resetGame()
                        } else {
                            
                        }
                    }
                }
            )
        }
        .padding(.top, 8)
        .background(Image(.metalico).resizable().scaledToFill().ignoresSafeArea(.container, edges: .bottom))
        .background(Color.black)
        .onAppear { gameCenterViewModel.authPlayer() }
    }
}
