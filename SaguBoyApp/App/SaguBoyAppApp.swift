//  SaguBoyAppApp.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 09/09/25.
//
import SwiftData
import SwiftUI



@main
struct SaguBoyAppApp: App {
    
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Ponctuation.self)
        } catch {
            fatalError("Failed to create ModelContainer for Ponctuation.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            GameView(dataViewModel: DataViewModel(modelContext: container.mainContext))
        }
        .modelContainer(container)
    }
}
