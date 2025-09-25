//
//  GameView.swift
//  POC-GameplayKit
//
//  Created by Vicenzo Másera on 03/09/25.
//
import SwiftUI
import SpriteKit
import SwiftData

// Enum para controlar qual tela está ativa
enum Screen {
    case menu
    case game
}

struct GameView: View {
    
    @State var gameCenterViewModel = GameCenterViewModel()
    @State var dataViewModel: DataViewModel
    
    // HUD state
    @State private var points: Int = 0
    @State private var lives: Int = 3
    @State private var powerups: Int = 0
    @State private var isGameOver: Bool = false
    
    // A cena do jogo é criada apenas quando necessária
    @State private var scene: GameScene? = nil
    
    // Controla a tela atual
    @State private var currentScreen: Screen = .menu
    
    var body: some View {
        // Usa uma ZStack para permitir transições suaves
        ZStack {
            if currentScreen == .menu {
                MenuView(onPlay: {
                    // Prepara e transiciona para a tela de jogo
                    prepareAndStartGame()
                })
                .transition(.opacity)
            } else if let scene = scene {
                gameplayView(scene: scene)
                    .transition(.opacity)
            }
        }
        .animation(.default, value: currentScreen)
        .onAppear { gameCenterViewModel.authPlayer() }
    }
    
    // Prepara a cena do jogo e muda a tela
    private func prepareAndStartGame() {
        let size = CGSize(width: 364, height: 415)
        let newScene = makeScene(size: size)
        self.scene = newScene
        self.currentScreen = .game
        
        // Garante que o jogo comece não pausado
        self.isGameOver = false
        self.lives = 3
        self.powerups = 0
        self.points = 0
    }
    
    // Função para criar a cena (movida para cá)
    private func makeScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill

        scene.onLivesChanged = { lives in
            self.lives = lives
        }
        scene.onGameOver = {
            Task { await gameCenterViewModel.submitScore(score: self.points, leaderboardID: "mainHighScore") }
            dataViewModel.addScore(value: self.points)
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

    // A view de gameplay foi extraída para um método auxiliar
    @ViewBuilder
    private func gameplayView(scene: GameScene) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color("consoleBackground"))
                    .frame(width: 380, height: 476)
                    .shadow(radius: 8)

                SpriteView(scene: scene)
                    .frame(width: 364, height: 415)
                    .clipped()
                    .padding(.top, 8)
                    .padding(.horizontal, 8)

                // HUD
                HStack(spacing: 8) {
                    Text("Vidas: ")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.leading, 12)
                    ForEach(0..<lives, id: \.self ) {_ in Image("heart").resizable().renderingMode(.original).frame(width: 12, height: 12) }
                    Text("Pontos: \(points)").font(.headline.monospacedDigit()).foregroundStyle(.white).padding(6)
                    Text("Power: \(powerups)/1").font(.headline.monospacedDigit()).foregroundStyle(.white).padding(6)
                }
                
                
                if isGameOver {
                    VStack(spacing: 60) {
                        Text("Your score: \(points)")
                            .foregroundStyle(.white)
                            .font(Font.custom("JetBrainsMonoNL-Regular", size: 16))
                            .bold()
                        
                        Text("You died")
                            .foregroundStyle(.white)
                            .font(Font.custom("JetBrainsMonoNL-Regular", size: 48))
                            .bold()
                        
                        VStack(spacing: 16) {
                            Text("press A to play again")
                                .foregroundStyle(.white)
                                .font(Font.custom("JetBrainsMonoNL-Regular", size: 16))
                            
                            Text("press START to return to menu")
                                .foregroundStyle(.white)
                                .font(Font.custom("JetBrainsMonoNL-Regular", size: 16))
                        }
                    }
                    .frame(width: 364, height: 415)
                    .background(Color.black.opacity(0.7))
                    .padding(.top, 8)
                    .padding(.horizontal, 8)
                }
            }
            
            Spacer()

            ControllersView(
                onDirection: { dir, pressed in scene.setDirection(dir, active: pressed) },
                onA: {
                    pressed in if pressed {
                        scene.handleA(pressed: pressed);
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        if isGameOver {
                            resetGame()
                        }
                    }
                },
                onB: { pressed in if pressed { scene.handleB(pressed: pressed); UIImpactFeedbackGenerator(style: .medium).impactOccurred() } },
                onStart: { pressed in
                    if pressed {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        scene.handleStart(pressed: pressed)
                        if isGameOver {
                            isGameOver = false
                            lives = 3
                            powerups = 0
                            points = 0
                            currentScreen = .menu
                        }
                    }
                }
            )
        }
        .padding(.top, 8)
        .background(Image("metalico").resizable().scaledToFill().ignoresSafeArea(.container, edges: .bottom))
        .background(Color.black)
    }
    
    private func resetGame() {
        isGameOver = false
        lives = 3
        powerups = 0
        points = 0
        scene?.resetGame()
    }
}
