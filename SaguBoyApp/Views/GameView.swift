//  GameView.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 03/09/25.
//
import SwiftUI
import SpriteKit
import SwiftData

enum Screen {
    case splash
    case menu
    case settings
    case game
    case leaderboard
}

struct GameView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State var gameCenterViewModel = GameCenterViewModel()
    var dataViewModel: DataViewModel
    @State private var lastStartTime: Date? = nil
    
    @State private var points: Int = 0
    @State private var lives: Int = 3
    @State private var powerups: Int = 0
    @State private var comboScore: Int = 1
    @State private var comboTimer: Double = 6.0
    
    @State private var isGameOver: Bool = false
    
    @State private var scene: GameScene? = nil
    @State private var currentScreen: Screen = .splash
    
    var body: some View {
        ZStack {
            switch currentScreen {
            case .splash:
                SplashScreenView(onSkip: {
                  currentScreen = .menu
                  if SettingsManager.shared.isSoundEnabled {
                    AudioManager.shared.playMENUTrack()
                  }
                })
                .transition(.opacity)

              case .menu:
                MenuView(
                  onPlay: { prepareAndStartGame() },
                  onSettings: { currentScreen = .settings },
                  onLeaderboard: { currentScreen = .leaderboard }
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
                .transition(.opacity)
                
            case .game:
                if let scene = scene {
                    gameplayView(scene: scene)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeOut(duration: 1.0), value: currentScreen)
        .onAppear {
            gameCenterViewModel.authPlayer()
            // Sai da splash depois de 3 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.120) {
                self.currentScreen = .menu
                
                // 🔊 Já inicia o tema do menu assim que o app abre
                if SettingsManager.shared.isSoundEnabled {
                    AudioManager.shared.playMENUTrack()
                }
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
                
                HStack() {
                    ForEach(0..<3, id: \.self) {
                        i in Image(i < lives ? "heartFill" : "heartEmpty")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 20, height: 18)
                    }
                    
                    
                    Text("SCORE: \(points.score9)")
                        .font(.custom("determination", size: 16))
                        .foregroundStyle(.white)
                        .padding(.leading, 8)
                    
                    HStack {
                        Text("POWER UP:")
                            .font(.custom("determination", size: 16))
                            .foregroundStyle(.white)
                        
                        Image(powerups > 0 ? "latinhaFill" : "latinhaEmpty")
                            .resizable()
                            .renderingMode(.original)
                            .frame(width: 16, height: 20)
                    }
                    .padding(.leading, 4)
                }
                .padding()
                
                if isGameOver {
                    VStack(spacing: 60) {
                        GameOverComponent(numerohighScore: points)
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
