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
        return scene
    }

    // HUD state
    @State private var points: Int = 0
    @State private var lives: Int = 3
    @State private var isGameOver: Bool = false
    @State private var scene: GameScene = GameScene()

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                        .onAppear {
                            scene = makeScene(size: CGSize(width: geo.size.width, height: geo.size.height))
                        }
                        .onChange(of: geo.size) { newSize in
                            scene.size = newSize
                        }

                    HStack {
                        Text("Vidas: \(lives)")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(.white)
                            .padding(12)
                        
                        Text("Pontos: \(points)")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(.white)
                            .padding(12)
                    }

                    if isGameOver {
                        Text("GAME OVER")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.5))
                            .onTapGesture {
                                isGameOver = false
                                lives = 3
                                scene.resetGame()
                            }
                    }
                }
            }
            .frame(height: 449)

            Spacer()

            ControllersView(
                onDirection: { dir, pressed in
                    scene.setDirection(dir, active: pressed)
                },
                onA: { pressed in
                    if pressed {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                },
                onB: { pressed in
                    if pressed {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                },
                onStart: { pressed in
                    if pressed {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        if isGameOver {
                            isGameOver = false
                            lives = 3
                            scene.resetGame()
                        } else {
                            
                        }
                    }
                }
            )
        }
        .background(Image(.metalico).resizable().scaledToFill().ignoresSafeArea())
        .onAppear { gameCenterViewModel.authPlayer() }
    }
}
