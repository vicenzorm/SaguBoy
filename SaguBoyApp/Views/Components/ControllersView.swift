//
//  DPadView.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 10/09/25.
//

import SwiftUI

struct ControllersView: View {
    // Saídas para o jogo
    let onDirection: (Direction, Bool) -> Void
    let onA: (Bool) -> Void
    let onB: (Bool) -> Void
    let onStart: (Bool) -> Void
    private let analogSize: CGFloat = 148
    
    var body: some View {
        VStack(spacing: 40) {
            // Logo
            Image(.saguboy)
                .resizable()
                .frame(width: 122, height: 23)
            
            HStack {
                // Analógico no lugar do D-Pad
                AnalogStick { dir, pressed in
                    if let d = dir {
                        onDirection(d, pressed)
                        
                    }
                }
                .frame(width: analogSize, height: analogSize)
                .padding(8)
                .accessibilityLabel("Analógico")
                
                Spacer()
                
                // Botões A e B
                HStack {
                    VStack {
                        Spacer()
                        Button {} label: {
                            Image(.buttonAB)
                                .resizable()
                                .frame(width: 71, height: 71)
                                .scaledToFill()
                                .accessibilityLabel("Botão B")
                        }
                        .buttonStyle(HoldButtonStyle { isDown in onB(isDown) })
                        Text("B")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.buttonclr)
                    }
                    VStack {
                        Button {} label: {
                            Image(.buttonAB)
                                .resizable()
                                .frame(width: 71, height: 71)
                                .scaledToFill()
                                .accessibilityLabel("Botão A")
                        }
                        .buttonStyle(HoldButtonStyle { isDown in onA(isDown) })
                        Text("A")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.buttonclr)
                        Spacer()
                    }
                }
                .frame(width: 142, height: 176)
                .padding(.trailing, 27)
            }
            
            // Botão Start
            Button {} label: {
                Image(.startButton)
                    .resizable()
                    .frame(width: 42, height: 19)
                    .scaledToFill()
                    .accessibilityLabel("Start")
            }
            .buttonStyle(HoldButtonStyle { isDown in onStart(isDown) })
        }
    }
}

struct HoldButtonStyle: ButtonStyle {
    var onChanged: (Bool) -> Void
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) {
                onChanged(configuration.isPressed)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
