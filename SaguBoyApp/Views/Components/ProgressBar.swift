//
//  ProgressBar.swift
//  SaguBoyApp
//
//  Created by Jean Pierre on 29/09/25.
//

import Foundation
import SwiftUI

import SwiftUI

struct ProgressBar: View {
    let duration: TimeInterval
    var restartKey: AnyHashable = 0       // use comboScore aqui
    var onFinished: (() -> Void)? = nil

    @State private var startedAt = Date()

    var body: some View {
        TimelineView(.animation) { ctx in
            let elapsed = ctx.date.timeIntervalSince(startedAt)
            let remaining = max(0, duration - elapsed)
            let progress = duration <= 0 ? 0 : max(0, min(1, remaining / duration))

            ZStack(alignment: .leading) {
                Capsule().fill(Color.gray.opacity(0.25))
                GeometryReader { geo in
                    Capsule()
                        .fill(LinearGradient(colors: [.green, .yellow, .red],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * progress)
                        .animation(.none, value: progress) // timeline controla
                }
            }
            .frame(height: 8)
        }
        // reinicia quando mudar o combo ou a duração
        .onChange(of: restartKey) { _ in startedAt = Date() }
        .onChange(of: duration)   { _ in startedAt = Date() }
        // dispara callback ao terminar
        .task(id: startedAt) {
            // agenda de forma cancelável se reiniciar antes de terminar
            try? await Task.sleep(nanoseconds: UInt64(max(0, duration) * 1_000_000_000))
            // garante que ninguém reiniciou no meio
            if Date().timeIntervalSince(startedAt) >= duration {
                onFinished?()
            }
        }
        .onAppear { startedAt = Date() }
        .accessibilityLabel("Barra de tempo restante")
    }
}
