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
                    
                    VStack(spacing: 16) {
                        Image("settingsTitle")
                            .resizable()
                            .renderingMode(.original)
                            .interpolation(.none)
                            .antialiased(false)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 166, height: 48)
                            .padding(.top, 16)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 0) {
                            settingOptionImage(for: .sounds)
                            settingOptionImage(for: .haptics)
                            
                            settingOptionImage(for: .back)
                                .padding(.top, 20)
                        }
                        .padding(.bottom, 20)
                        .padding(.leading, 180)
                        
                        Spacer()
                    }
                }
                .frame(width: 364, height: 415)
                .background(
                    Image("settingsBackground")
                        .resizable()
                        .scaledToFill()
                )
                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
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
    
    // MARK: - Opção como IMAGEM (mapeia seleção + estado atual do setting)
    @ViewBuilder
    private func settingOptionImage(for option: SettingsOption) -> some View {
        let isSelected = viewModel.selectedOption == option
        Image(assetName(for: option, selected: isSelected))
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
            .padding(.vertical, 4)
            .animation(.bouncy(duration: 0.2), value: viewModel.selectedOption)
    }
    
    private func assetName(for option: SettingsOption, selected: Bool) -> String {
        switch option {
        case .sounds:
            let sel   = selected ? "Enable" : "Disable"
            let state = settings.isSoundEnabled ? "On" : "Off"
            return "settingsSound\(sel)\(state)"          // ex.: settingsSoundEnableOn
        case .haptics:
            let sel   = selected ? "Enable" : "Disable"
            let state = settings.isHapticsEnabled ? "On" : "Off"
            return "settingsHaptics\(sel)\(state)"        // ex.: settingsHapticsDisableOff
        case .back:
            return selected ? "settingsBackEnable" : "settingsBackDisable"
        }
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
            default: break
            }
        } else if dir == directionPressed {
            directionPressed = nil
        }
    }
}
