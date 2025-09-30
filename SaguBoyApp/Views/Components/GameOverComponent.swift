//
//  GameOverComponent.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 30/09/25.
//

import SwiftUI

struct GameOverComponent: View {
    
    let numerohighScore: Int
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                Image(.defeatBackground)
                VStack {
                    VStack(spacing: 8){
                        Text("Your highscore was:")
                            .font(.custom("determination", size: 13))
                            .foregroundStyle(.seaBlue)
                        
                        Text("\(numerohighScore.score9)")
                            .font(.custom("determination", size: 24))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8){
                        Text("Press A to play again")
                            .font(.custom("determination", size: 13))
                            .foregroundStyle(.white)
                        
                        Text("Press START to return to menu")
                            .font(.custom("determination", size: 13))
                            .foregroundStyle(.seaBlue)
                    }
                }
                .padding(.top, 48)
                .padding(.bottom, 36)
            }
            .frame(width: 309, height: 263)
            
            ZStack {
                Image(.defeatBanner)
                Text("YOU LOSE")
                    .font(.custom("determination", size: 32))
                    .foregroundStyle(.white)
            }
            .padding(.top, -24)
        }
    }
}

#Preview {
    GameOverComponent(numerohighScore: 20)
}
