//  GameView.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 03/09/25.
//
import SwiftUI
import SpriteKit
import SwiftData

enum Screen {
    case menu
    case settings
    case game
    case leaderboard
}

struct GameView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State var gameCenterViewModel = GameCenterViewModel()
    var dataViewModel: DataViewModel
    
    @State private var points: Int = 0
    @State private var lives: Int = 3
    @State private var powerups: Int = 0
    @State private var comboScore: Int = 1
    @State private var comboTimer: Double = 6.0

    @State private var isGameOver: Bool = false
    
    @State private var scene: GameScene? = nil
    @State private var currentScreen: Screen = .menu
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .menu:
                MenuView(
                    onPlay: { prepareAndStartGame() },
                    onSettings: { currentScreen = .settings },
                    onLeaderboard: { currentScreen = .leaderboard } // <-- Adicionado
                )
                .transition(.opacity)
            case .settings:
                SettingsView(onBack: { returnToMenu() })
                    .transition(.opacity)
            case .leaderboard:
                LeaderboardView(
                    dataViewModel: dataViewModel,
                    onBack: { returnToMenu() }
                )
            case .game:
                if let scene = scene {
                    gameplayView(scene: scene)
                        .transition(.opacity)
                }
            }
        }
        .animation(.default, value: currentScreen)
        .onAppear {
            gameCenterViewModel.authPlayer()
            // 🔊 Já inicia o tema do menu assim que o app abre
            if SettingsManager.shared.isSoundEnabled {
                AudioManager.shared.playMENUTrack()
            }
        }
    }
    
    private func prepareAndStartGame() {
        let size = CGSize(width: 364, height: 415)
        let newScene = makeScene(size: size)
        AudioManager.shared.stopMusic()
        self.scene = newScene
        self.currentScreen = .game
        if SettingsManager.shared.isSoundEnabled {
            AudioManager.shared.playGAMETrack()
        }
        
        // Garante que o jogo comece não pausado
        self.isGameOver = false
        self.lives = 3
        self.powerups = 0
        self.points = 0
        self.comboScore = 1
        self.comboTimer = 8.0
    }
    
    private func makeScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.onLivesChanged = { lives in self.lives = lives }
        scene.onGameOver = {
            Task { await gameCenterViewModel.submitScore(score: self.points, leaderboardID: "mainHighScore") }
            dataViewModel.addScore(value: self.points)
            print(dataViewModel.scores)
            self.isGameOver = true
            
            // 🔊 Para música do jogo (ou derrota) e volta para o tema do menu
            if SettingsManager.shared.isSoundEnabled {
                AudioManager.shared.stopMusic()
                AudioManager.shared.playMENUTrack()
            }
        }
        scene.onPointsChanged = { points in self.points = points }
        scene.onPowerupChanged = { self.powerups = $0 }
        scene.onComboScoreChanged = { combo in self.comboScore = combo}
        scene.onComboTimerChanged = { time in self.comboTimer = time}
        return scene
    }
    
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
                    .padding([.top, .horizontal], 8)
                
                Text("SaguBoy")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.consoleText)
                    .padding(.top, 450)
                    .padding(.leading, 8)
                
                Text("Color SB")
                    .font(.system(size: 8, weight: .regular))
                    .foregroundStyle(.consoleText)
                    .padding(.top, 445)
                    .padding(.leading, 77)
                
                HStack(spacing: 8) {
                    Text("Vidas: ").font(.footnote.monospacedDigit().bold()).foregroundStyle(.white).padding(.leading, 12).font(.system(size: 12))
                    ForEach(0..<lives, id: \.self ) {_ in Image("heart").resizable().renderingMode(.original).frame(width: 12, height: 12) }
                    Text("Pontos: \(points)").font(.footnote.monospacedDigit().bold()).foregroundStyle(.white)
                    Text("Power: \(powerups)/1").font(.footnote.monospacedDigit().bold()).foregroundStyle(.white)
                    
                    if comboScore > 1 {
                        Text("\(comboScore)X").font(.footnote.monospacedDigit().bold()).foregroundStyle(.yellow)
                        ProgressBar(duration: comboTimer, restartKey: comboScore) {
                            scene.resetCombo()
                                
                          }
                        .frame(width: 56)
                    }
                    
                }
                .padding(.top, 8)
                
                if isGameOver {
                    VStack(spacing: 60) {
                        Text("Your score: \(points)").foregroundStyle(.white).font(.custom("JetBrainsMonoNL-Regular", size: 16)).bold()
                        Text("You died").foregroundStyle(.white).font(.custom("JetBrainsMonoNL-Regular", size: 48)).bold()
                        VStack(spacing: 16) {
                            Text("press A to play again").foregroundStyle(.white).font(.custom("JetBrainsMonoNL-Regular", size: 16))
                            Text("press START to return to menu").foregroundStyle(.white).font(.custom("JetBrainsMonoNL-Regular", size: 16))
                        }
                    }
                    .frame(width: 364, height: 415).background(Color.black.opacity(0.7)).padding([.top, .horizontal], 8)
                }
            }
            
            Spacer()
            
            ControllersView(
                onDirection: { dir, pressed in scene.setDirection(dir, active: pressed) },
                onA: { pressed in
                    if pressed {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        if isGameOver { resetGame() } else { scene.handleA(pressed: pressed) }
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
        .background(Image("metalico").resizable().scaledToFill()
            .ignoresSafeArea(.container, edges: .bottom))
        .background(Color.black)
        
    }
    
    private func resetGame() {
        isGameOver = false
        lives = 3
        powerups = 0
        points = 0
        scene?.resetGame()
    }
    
    private func returnToMenu() {
        isGameOver = false
        lives = 3
        powerups = 0
        points = 0
        scene = nil
        currentScreen = .menu
    }
}
