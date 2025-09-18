//  AnalogStick.swift
//  SaguBoyApp
//
//  Created by Bernardo Garcia Fensterseifer on 17/09/25.
//

import SwiftUI

struct AnalogStick: View {
    @State private var dragOffset: CGSize = .zero
    
    let stickRadius: CGFloat = 60
    var onDirectionChanged: (Direction?, Bool) -> Void
    
    @State private var currentDirection: Direction?
    
    // Gerador de feedback háptico
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack(alignment: .center) {
            // Base (hexágono)
            Image(.hexagon)
                .resizable()
                .frame(width: 120, height: 120, alignment: .center)

            // Stick (joystick)
            Image(.bola)
                .resizable()
                .frame(width: 80, height: 80, alignment: .center)
//                .aspectRatio(contentMode: .fit)
                .offset(dragOffset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let vector = CGSize(
                                width: value.translation.width,
                                height: -value.translation.height // 👈 inverte Y
                            )
                            let distance = sqrt(vector.width * vector.width + vector.height * vector.height)
                            let angle = atan2(vector.height, vector.width)

                            // limitar dentro do círculo
                            if distance <= stickRadius {
                                dragOffset = CGSize(width: vector.width, height: -vector.height)
                            } else {
                                dragOffset = CGSize(
                                    width: cos(angle) * stickRadius,
                                    height: -sin(angle) * stickRadius
                                )
                            }

                            // detectar direção
                            let newDir = directionFromAngle(angle, distance: distance)

                            if newDir != currentDirection {
                                if newDir != nil { feedbackGenerator.impactOccurred() }
                                if let cur = currentDirection { onDirectionChanged(cur, false) }
                                if let nd = newDir { onDirectionChanged(nd, true) }
                                currentDirection = newDir
                            }
                        }
                        .onEnded { _ in
                            dragOffset = .zero
                            if let cur = currentDirection {
                                onDirectionChanged(cur, false)
                                currentDirection = nil
                            }
                        }
                )
        }
        .onAppear {
            // Preparar o gerador de feedback para resposta mais rápida
            feedbackGenerator.prepare()
        }
    }
    
    private func directionFromAngle(_ angle: CGFloat, distance: CGFloat) -> Direction? {
        let deadZone: CGFloat = 15
        guard distance > deadZone else { return nil }
        
        // converter para graus (0 a 360)
        var degrees = angle * 180 / .pi
        if degrees < 0 { degrees += 360 }
        
        switch degrees {
        case 337.5..<360, 0..<22.5:
            return .right
        case 22.5..<67.5:
            return .upRight
        case 67.5..<112.5:
            return .up
        case 112.5..<157.5:
            return .upLeft
        case 157.5..<202.5:
            return .left
        case 202.5..<247.5:
            return .downLeft
        case 247.5..<292.5:
            return .down
        case 292.5..<337.5:
            return .downRight
        default:
            return nil
        }
    }
}
