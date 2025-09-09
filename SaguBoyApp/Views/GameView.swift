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
        .frame(maxWidth: .infinity, maxHeight: 444)
        .onAppear {
            self.viewModel.startGame()
        }
        
        Spacer()
    }
}

#Preview {
    GameView()
}
