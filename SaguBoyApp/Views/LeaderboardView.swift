//
//  LeaderboardView.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 25/09/25.
//

import SwiftUI

struct LeaderboardView: View {
    
    @State private var viewModel = LeaderboardViewModel()
    @State private var dataViewModel: DataViewModel
    
    var onBack: () -> Void
    
    init(dataViewModel: DataViewModel, onBack: @escaping () -> Void) {
        self._dataViewModel = State(initialValue: dataViewModel)
        self.onBack = onBack
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack(alignment: .topLeading) {
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color("consoleBackground"))
                    .frame(width: 380, height: 476)
                    .shadow(radius: 8)
                
                ZStack {
                    VStack(spacing: 16) {
                                                
                        VStack {
                            if dataViewModel.scores.isEmpty {
                                Text("No scores yet!")
                                    .font(Font.custom("JetBrainsMonoNL-Regular", size: 20))
                                    .foregroundColor(.white)
                            } else {
                                ForEach(Array(dataViewModel.scores.enumerated()), id: \.element.id) { index, score in
                                    leaderboardRow(rank: index + 1, score: score.score)
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 110)
                        
                        Spacer()
                        
                        leaderboardRow(for: .back)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .frame(width: 364, height: 415)
                .background(
                    Image("leaderboardBackground")
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                .padding(.top, 8)
                .padding(.horizontal, 8)
                
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
            }
            
            Spacer()
            
            ControllersView(
                onDirection: { _,_  in },
                onA: { _ in onBack() },
                onB: { _ in onBack() },// Botão B para voltar
                onStart: { _ in }
            )
            
        }
        .padding(.top, 8)
        .background(Image("metalico").resizable().scaledToFill()
            .ignoresSafeArea(.container, edges: .bottom))
        .background(Color.black)
        .onAppear {
            dataViewModel.fetchScores(limit: 5)
            viewModel.onBack = onBack
        }
    }
    
    @ViewBuilder
    private func leaderboardRow(rank: Int, score: Int) -> some View {
        HStack {
            Text("\(rank).")
            Spacer()
            Text("\(score)")
        }
        .font(Font.custom("Determination", size: 22))
        .foregroundStyle(rank == 1 ? Color.orange : .blackBrown)
        .padding(.bottom, 8)
    }

    
    @ViewBuilder
    private func leaderboardRow(for option: LeaderboardOption) -> some View {
        let isSelected = viewModel.selectedOption == option
        Image("leaderboardBackButton")
            .resizable()
            .renderingMode(.original)
            .interpolation(.none)
            .antialiased(false)
            .aspectRatio(contentMode: .fit)
            .frame(width: 130, height: 35)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectedOption = option
                if SettingsManager.shared.isHapticsEnabled {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
}
