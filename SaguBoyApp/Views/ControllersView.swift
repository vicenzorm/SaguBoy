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
    
    private func key(_ name: String, dir: Direction) -> some View {
        Button(action: {}) {
            Image(name)
                .frame(width: 45, height: 58)
                .scaledToFill()
        }
        .buttonStyle(HoldButtonStyle { isPressed in onDirection(dir, isPressed) })
    }
    
    var body: some View {
        HStack {
            VStack(spacing: -8) {
                key("upButton",    dir: .up)
                HStack(spacing: 2) {
                    key("leftButton",  dir: .left)
                    Circle()
                        .frame(width: 45, height: 45)
                        .hidden()
                    key("rightButton", dir: .right)
                }
                key("downButton",  dir: .down)
            }
            .padding(8)
            Spacer()
            Buttons {
                onAChanged()
            } onBChanged: {
                onBChanged()
            }

        }
        .padding(.horizontal, 8)
        .padding(.bottom, 79)
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

struct Buttons: View {
    var onAChanged: () -> Void
    var onBChanged: () -> Void
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 27)
                .stroke(Color.gray,lineWidth: 3)
                .frame(width: 188, height: 178)
                .cornerRadius(27)
                .background(.buttonsStack)
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
}


struct StartButton: View {
    var body: some View {
        Image(.startButton)
            .resizable()
            .frame(width: 42, height: 19)
            .scaledToFill()
    }
}


#Preview {
}
