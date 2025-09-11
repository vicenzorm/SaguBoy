//
//  GameView.swift
//  POC-GameplayKit
//
//  Created by Vicenzo Másera on 03/09/25.
//
import SwiftUI

struct GameView: View {
    var viewModel = GameViewModel()
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Circle()
                    .fill(Color.green)
                    .frame(width: viewModel.player.size, height: viewModel.player.size)
                    .position(viewModel.player.position)
                
                
                ForEach(viewModel.enemies) { enemy in
                    Circle()
                        .fill(Color.red)
                        .frame(width: enemy.size, height: enemy.size)
                        .position(enemy.position)
                }
                
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 449)
            
            VStack {
                Spacer()
                HStack {
                    ControllersView(
                        onDirection: { dir, isPressed in viewModel.setDirection(dir, active: isPressed) },
                        onAChanged: {
                            
                        },
                        onBChanged: {
                            
                        }
                    )
                    .padding(.bottom, 16)
                    Spacer()
                }
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            self.viewModel.startGame()
        }
        .onDisappear {
            self.viewModel.stopGame()
        }
        
        Spacer()
    }
}

#Preview {
    GameView()
}
