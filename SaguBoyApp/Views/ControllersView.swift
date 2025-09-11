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
    
    private func key(_ systemName: String, dir: Direction) -> some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.title2.weight(.bold))
                .frame(width: 56, height: 56)
                .background(Circle().fill(.white.opacity(0.08)))
                .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 1))
                .contentShape(Circle())
        }
        .buttonStyle(HoldButtonStyle { isPressed in onDirection(dir, isPressed) })
    }
    
    var body: some View {
        HStack {
            VStack(spacing: 8) {
                key("arrowtriangle.up.fill",    dir: .up)
                HStack(spacing: 8) {
                    key("arrowtriangle.left.fill",  dir: .left)
                    Circle().fill(.clear).frame(width: 40, height: 40) // dead zone
                    key("arrowtriangle.right.fill", dir: .right)
                }
                key("arrowtriangle.down.fill",  dir: .down)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.black.opacity(0.35))
                    .blur(radius: 0.5)
            )
            Spacer()
            Buttons {
                onAChanged()
            } onBChanged: {
                onBChanged()
            }

        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
            HStack {
                VStack {
                    Spacer()
                    Button {
                        onAChanged()
                    } label: {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 71, height: 71)
                    }
                }
                VStack {
                    Button {
                        onBChanged()
                    } label: {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 71, height: 71)
                    }
                    Spacer()
                }
            }
            .frame(width: 158, height: 148)
        }
    }
}

#Preview {
}
