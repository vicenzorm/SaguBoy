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

    private let dpadSize: CGFloat = 148
    private let deadZone: CGFloat = 18

    @State private var currentDirection: Direction?
    
    private var dpadImage: Image {
        switch currentDirection {
        case .some(.up):    return Image(.dpadCima)
        case .some(.down):  return Image(.dpadBaixo)
        case .some(.left):  return Image(.dpadEsquerda)
        case .some(.right): return Image(.dpadDireita)
        case .none:         return Image(.dpad)
        }
    }

    var body: some View {
        VStack(spacing: 40) {
            Image(.saguboy)
                .resizable()
                .frame(width: 122, height: 23)
            HStack {
                ZStack {
                    GeometryReader { geo in
                        let size = geo.size
                        dpadImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onChanged { value in
                                        let center = CGPoint(x: size.width/2, y: size.height/2)
                                        let dx = value.location.x - center.x
                                        let dy = value.location.y - center.y
                                        let dist = sqrt(dx*dx + dy*dy)
                                        guard dist >= deadZone else {
                                            if let cur = currentDirection {
                                                currentDirection = nil
                                                onDirection(cur, false)
                                            }
                                            return
                                        }
                                        let newDir: Direction = abs(dx) > abs(dy) ? (dx > 0 ? .right : .left)
                                                                                 : (dy > 0 ? .down  : .up)
                                        if newDir != currentDirection {
                                            if let cur = currentDirection { onDirection(cur, false) }
                                            currentDirection = newDir
                                            onDirection(newDir, true)
                                        }
                                    }
                                    .onEnded { _ in
                                        if let cur = currentDirection {
                                            currentDirection = nil
                                            onDirection(cur, false)
                                        }
                                    }
                            )
                    }
                }
                .frame(width: dpadSize, height: dpadSize)
                .padding(8)
                .accessibilityLabel("Direcional")

                Spacer()

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
