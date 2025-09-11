//
//  GameView.swift
//  POC-GameplayKit
//
//  Created by Vicenzo Másera on 03/09/25.
//
import SwiftUI

struct GameView: View {
    @State private var viewModel = GameViewModel()

    var body: some View {
        VStack (spacing: 0) {
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
                    VStack(spacing: 12) {
                        Text("GAME OVER")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                        Button("Tentar de novo") { viewModel.resetGame() }
                            .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 449)

            VStack {
                Spacer()
                HStack {
                    ControllersView(
                        onDirection: { dir, isPressed in viewModel.setDirection(dir, active: isPressed) },
                        onAChanged: { },
                        onBChanged: { }
                    )
                    .padding(.bottom, 16)
                    Spacer()
                }
                .padding(.bottom, 16)
            }
        }
        .onAppear { viewModel.startGame() }
        .onDisappear { viewModel.stopGame() }

        Spacer()
    }
}

#Preview {
    GameView()
}
