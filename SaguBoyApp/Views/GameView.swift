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
    
    @State private var points: Int = 0
    @State private var lives: Int = 3
    @State private var powerups: Int = 0
    @State private var isGameOver: Bool = false
    
    @State private var scene: GameScene? = nil
    @State private var currentScreen: Screen = .splash

    var body: some View {
        ZStack {
            switch currentScreen {
            case .splash:
                SplashScreenView()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.currentScreen = .menu
            }
        }
    }

    
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
    
    private func makeScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.onLivesChanged = { lives in self.lives = lives }
        scene.onGameOver = {
            Task { await gameCenterViewModel.submitScore(score: self.points, leaderboardID: "mainHighScore") }
            dataViewModel.addScore(value: self.points)
            print(dataViewModel.scores)
            self.isGameOver = true
        }
        scene.onPointsChanged = { points in self.points = points }
        scene.onPowerupChanged = { self.powerups = $0 }
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
                    Text("Vidas: ").fontWeight(.semibold).foregroundStyle(.white).padding(.leading, 12)
                    ForEach(0..<lives, id: \.self ) {_ in Image("heart").resizable().renderingMode(.original).frame(width: 12, height: 12) }
                    Text("Pontos: \(points)").font(.headline.monospacedDigit()).foregroundStyle(.white).padding(6)
                    Text("Power: \(powerups)/1").font(.headline.monospacedDigit()).foregroundStyle(.white).padding(6)
                }
                
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
        AudioManager.shared.stopMusic()
        isGameOver = false
        lives = 3
        powerups = 0
        points = 0
        scene = nil
        currentScreen = .menu
    }
}
