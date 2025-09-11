//
//  DPadView.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 10/09/25.
//

import SwiftUI

struct ControllersView: View {
    let onDirection: (Direction, Bool) -> Void
    
    var onAChanged: () -> Void
    var onBChanged: () -> Void
    
    var onStartClicked: () -> Void
    
    var body: some View {
        VStack(spacing: 39) {
            HStack {
                ZStack {
                    Image(.dpad)
                        .frame(width: 136, height: 136)
                        .scaledToFill()
                    VStack(spacing: 0) {
                        directionInvisibleButton(dir: .up)
                        HStack(spacing: 2) {
                            directionInvisibleButton(dir: .left)
                            Circle()
                                .frame(width: 45, height: 45)
                                .hidden()
                            directionInvisibleButton(dir: .right)
                        }
                        directionInvisibleButton(dir: .down)
                    }
                }
                .padding(8)
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 27)
                        .stroke(Color.gray,lineWidth: 3)
                        .frame(width: 188, height: 178)
                        .cornerRadius(27)
//                        .background(.buttonsStack)
                    HStack {
                        VStack {
                            Spacer()
                            Button {
                                onAChanged()
                            } label: {
                                Image(.redButton)
                                    .resizable()
                                    .frame(width: 71, height: 71)
                                    .scaledToFill()
                            }
                        }
                        VStack {
                            Button {
                                onBChanged()
                            } label: {
                                Image(.yellowbutton)
                                    .resizable()
                                    .frame(width: 71, height: 71)
                                    .scaledToFill()
                            }
                            Spacer()
                        }
                    }
                    .frame(width: 158, height: 148)
                }
            }
            
            Button {
                onStartClicked()
            } label: {
                Image(.startButton)
                    .resizable()
                    .frame(width: 42, height: 19)
                    .scaledToFill()
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 20)
    }
    
    private func directionInvisibleButton(dir: Direction) -> some View {
        Button(action: {}) {
            RoundedRectangle(cornerRadius: 0)
                .frame(width: 45, height: 45)
                .opacity(1/1000000)
        }
        .buttonStyle(HoldButtonStyle { isPressed in onDirection(dir, isPressed) })
    }
}

struct HoldButtonStyle: ButtonStyle {
    var onChanged: (Bool) -> Void
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { onChanged($0) }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
}
