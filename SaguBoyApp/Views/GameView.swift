//
//  GameView.swift
//  POC-GameplayKit
//
//  Created by Vicenzo Másera on 03/09/25.
//
import SwiftUI

struct GameView: View {
    
    @State private var viewModel = GameViewModel()
    @State private var gameCenterViewModel = GameCenterViewModel()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack(alignment: .topLeading) {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    // Player
                    Circle()
                        .fill(Color.green)
                        .frame(width: viewModel.player.size, height: viewModel.player.size)
                        .position(viewModel.player.position)
                    
                    // Enemies
                    ForEach(viewModel.enemies) { enemy in
                        Circle()
                            .fill(Color.red)
                            .frame(width: enemy.size, height: enemy.size)
                            .position(enemy.position)
                    }
                    
                    // Texto simples de vidas
                    Text("Vidas: \(viewModel.player.lifes)")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.white)
                        .padding(12)
                    
                    // Overlay de Game Over (opcional)
                    if viewModel.gameOver {
                        Text("GAME OVER")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 449)
                
                Spacer()
                
                ControllersView(
                    onDirection: { dir, pressed in viewModel.setDirection(dir, active: pressed) },
                    onA: { pressed in viewModel.handleA(pressed) },
                    onB: { pressed in viewModel.handleB(pressed) },
                    onStart: { pressed in viewModel.handleStart(pressed) }
                )
            }
        }
        .onAppear() {
            gameCenterViewModel.authPlayer()
        }
        .background(Image(.metalico).resizable().scaledToFill().ignoresSafeArea())
        .onDisappear { viewModel.stopGame() }
    }
}
