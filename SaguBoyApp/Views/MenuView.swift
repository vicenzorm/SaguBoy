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
                
                ZStack {
                    GIFView(gifName: "backgroundPlaceholder").scaledToFill().frame(width: 364, height: 415)
                    
                    VStack(spacing: 15) {
                        
                        Text("v1.0.0")
                            .font(Font.custom("JetBrainsMonoNL-Regular", size: 20))
                            .foregroundStyle(.white)
                            .rotationEffect(Angle(degrees: 20))
                            .padding(.leading, 180)
                        
                        Image("shiro")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .padding(.bottom, 30)
                        
                        menuOptionText(for: .play)
                        menuOptionText(for: .settings)
                        menuOptionText(for: .leaderboard)
                    }
                }
                .frame(width: 364, height: 415)
                .background(
                        GIFView(gifName: "backgroundGIF")
                        .frame(width: 361, height: 415)
                )
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
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                },
                onB: { _ in },
                onStart: { pressed in
                    if pressed {
                        viewModel.selectCurrentOption()
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
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
        }
    }
    
    @ViewBuilder
    private func menuOptionText(for option: MenuOption) -> some View {
        let isSelected = viewModel.selectedOption == option
        Text(String(describing: option))
            .font(.custom("JetBrainsMonoNL-Regular", size: 24))
            .bold()
            .foregroundStyle(isSelected ? .black : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(isSelected ? Color.white : Color.clear)
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.bouncy(duration: 0.2), value: viewModel.selectedOption)
    }
    
    private func handleDirection(dir: Direction, pressed: Bool) {
        if pressed {
            if dir == directionPressed { return }
            directionPressed = dir
            
            switch dir {
            case .up, .upLeft, .upRight:
                viewModel.navigateUp()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .down, .downLeft, .downRight:
                viewModel.navigateDown()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
