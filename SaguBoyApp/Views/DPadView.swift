//
//  DPadView.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 10/09/25.
//

import SwiftUI

struct DPadView: View {
    let onDirection: (Direction, Bool) -> Void
    
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
