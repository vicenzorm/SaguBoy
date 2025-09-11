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
    
    private let dpadSize: CGFloat = 148
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
                
                HStack {
                    VStack {
                        Spacer()
                        Button {
                            onBChanged()
                        } label: {
                            Image(.buttonAB)
                                .resizable()
                                .frame(width: 71, height: 71)
                                .scaledToFill()
                                .accessibilityLabel("Botão A")
                        }
                        Text("B")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.buttonclr)
                    }
                    VStack {
                        Button {
                            onAChanged()
                        } label: {
                            Image(.buttonAB)
                                .resizable()
                                .frame(width: 71, height: 71)
                                .scaledToFill()
                                .accessibilityLabel("Botão B")
                        }
                        Text("A")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.buttonclr)
                        Spacer()
                    }
                }
                .frame(width: 142, height: 176)
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
    }
    
    
    private func direction(from point: CGPoint,
                           center: CGPoint,
                           deadZone: CGFloat) -> Direction? {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let dist = sqrt(dx*dx + dy*dy)
        
        guard dist >= deadZone else { return nil }
        
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
