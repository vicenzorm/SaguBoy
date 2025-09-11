//
//  DPadView.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 10/09/25.
//

import SwiftUI

struct ControllersView: View {
    // Callbacks
    let onDirection: (Direction, Bool) -> Void
    var onAChanged: () -> Void
    var onBChanged: () -> Void
    var onStartClicked: () -> Void

    @State private var currentDirection: Direction? = nil

    private let dpadSize: CGFloat = 136
    private let deadZone: CGFloat = 18 

    var body: some View {
        VStack(spacing: 39) {
            HStack {

                ZStack {
                    GeometryReader { geo in
                        let size = geo.size
                        let center = CGPoint(x: size.width/2, y: size.height/2)

                        Image(.dpad)
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                    .onChanged { value in
                                        if let newDir = direction(from: value.location,
                                                                 center: center,
                                                                 deadZone: deadZone) {
                                            if newDir != currentDirection {
                                                if let cur = currentDirection { onDirection(cur, false) }
                                                currentDirection = newDir
                                                onDirection(newDir, true)
                                            }
                                        } else {
                                            
                                            if let cur = currentDirection {
                                                currentDirection = nil
                                                onDirection(cur, false)
                                            }
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

                ZStack {
                    RoundedRectangle(cornerRadius: 27)
                        .stroke(Color.gray, lineWidth: 3)
                        .frame(width: 188, height: 178)

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
                                    .accessibilityLabel("Botão A")
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
                                    .accessibilityLabel("Botão B")
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
                    .accessibilityLabel("Start")
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 20)
    }


    /// Converte a posição do dedo em uma direção cardinal com zona morta.
    private func direction(from point: CGPoint,
                           center: CGPoint,
                           deadZone: CGFloat) -> Direction? {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let dist = sqrt(dx*dx + dy*dy)

        guard dist >= deadZone else { return nil } // zona morta central

        // Eixo dominante: horizontal vs vertical
        if abs(dx) > abs(dy) {
            return dx > 0 ? .right : .left
        } else {
            return dy > 0 ? .down : .up
        }
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
