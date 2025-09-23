//
//  SaguBoyAppApp.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 09/09/25.
//
import SwiftData
import SwiftUI

@main
struct SaguBoyAppApp: App {
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some Scene {
        WindowGroup {
            GameView(dataViewModel: DataViewModel(modelContext: modelContext))
        }
        .modelContainer(for: [
            Ponctuation.self
        ])
    }
}
