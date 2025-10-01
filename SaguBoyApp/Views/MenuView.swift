//
//  MenuView.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 23/09/25.
//

import SwiftUI

struct MenuView: View {
    
    @State private var viewModel = MenuViewModel()
    
    var onPlay: () -> Void
    var onSettings: () -> Void
    var onLeaderboard: () -> Void
    
    @State private var directionPressed: Direction? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack(alignment: .topLeading) {
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color("consoleBackground"))
                    .frame(width: 380, height: 476)
                    .shadow(radius: 8)
                
                ZStack (){
                    
                    VStack(spacing: 77) {
                        
                        Image("menuTitle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 214, height: 66)
                            .padding(.trailing, 110)
                            .padding(.top, 40)
                            
                        
                        VStack {
                            menuOptionImage(for: .play)
                            menuOptionImage(for: .settings)
                            menuOptionImage(for: .leaderboard)
                        }
                        .padding(.trailing, 170)
                        
                        Spacer()
                    }
                }
                .frame(width: 364, height: 415)
                .background(
                    Image("menuBackground")
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
                onDirection: handleDirection,
                onA: { pressed in
                    if pressed {
                        viewModel.selectCurrentOption()
                        if SettingsManager.shared.isHapticsEnabled {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        }
                    }
                },
                onB: { _ in },
                onStart: { pressed in
                    if pressed {
                        viewModel.selectCurrentOption()
                        if SettingsManager.shared.isHapticsEnabled {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        }
                    }
                }
            )
        }
        .padding(.top, 8)
        .background(Image("metalico").resizable().scaledToFill()
            .ignoresSafeArea(.container, edges: .bottom))
        .background(Color.black)
        .onAppear {
            viewModel.onPlay = onPlay
            viewModel.onSettings = onSettings
            viewModel.onLeaderboard = onLeaderboard
//            AudioManager.shared.stopMusic()
//            AudioManager.shared.playMENUTrack()
        }
    }
    
    @ViewBuilder
    private func menuOptionImage(for option: MenuOption) -> some View {
        let isSelected = viewModel.selectedOption == option
        Image(option.assetName(selected: isSelected))
            .resizable()
            .renderingMode(.original)
            .interpolation(.none)
            .antialiased(false)
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 35)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectedOption = option
                if SettingsManager.shared.isHapticsEnabled {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
    }
    
    private func handleDirection(dir: Direction, pressed: Bool) {
        if pressed {
            if dir == directionPressed { return }
            directionPressed = dir
            
            switch dir {
            case .up, .upLeft, .upRight:
                viewModel.navigateUp()
                if SettingsManager.shared.isHapticsEnabled {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            case .down, .downLeft, .downRight:
                viewModel.navigateDown()
                if SettingsManager.shared.isHapticsEnabled {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            default:
                break
            }
        } else {
            if dir == directionPressed {
                directionPressed = nil
            }
        }
    }
}
