//
//  SettingsView.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 24/09/25.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var viewModel = SettingsViewModel()
    @State private var settings = SettingsManager.shared
    
    var onBack: () -> Void
    
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
                    
                    VStack(spacing: 16) {
                        Text("settings")
                            .font(Font.custom("JetBrainsMonoNL-Regular", size: 30))
                            .foregroundColor(.white)
                            .padding(.top, 16)
                        
                        Spacer()
                        
                        settingOptionRow(for: .sounds, isOn: settings.isSoundEnabled)
                        settingOptionRow(for: .haptics, isOn: settings.isHapticsEnabled)
                        
                        Spacer()
                        
                        settingOptionRow(for: .back, isOn: false)
                            .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .frame(width: 364, height: 415)
                .clipped()
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
                        viewModel.toggleSelectedOption()
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                },
                onB: { _ in onBack() }, // Botão B para voltar
                onStart: { _ in }
            )
            
        }
        .padding(.top, 8)
        .background(Image("metalico").resizable().scaledToFill()
        .ignoresSafeArea(.container, edges: .bottom))
        .background(Color.black)
        .onAppear {
            viewModel.onBack = onBack
        }
    }
    
    @ViewBuilder
    private func settingOptionRow(for option: SettingsOption, isOn: Bool) -> some View {
        let isSelected = viewModel.selectedOption == option
        
        HStack {
            Text(String(describing: option))
                .font(.custom("JetBrainsMonoNL-Regular", size: 22))
            
            
            if option != .back {
                Spacer()
                Text(isOn ? "on" : "off")
                    .font(.custom("JetBrainsMonoNL-Bold", size: 22))
            }
        }
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
