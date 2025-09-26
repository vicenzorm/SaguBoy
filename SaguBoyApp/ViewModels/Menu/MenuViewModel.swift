//
//  MenuViewModel.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 23/09/25.
//

import Foundation
import GameplayKit

@Observable
@MainActor
class MenuViewModel {
    
    var selectedOption: MenuOption = .play
    
    private var stateMachine: GKStateMachine!
    
    var onPlay: () -> Void = {}
    var onSettings: () -> Void = {}
    var onLeaderboard: () -> Void = {}
    
    init() {
        let playState = MenuPlayState(viewModel: self, option: .play)
        let settingsState = MenuSettingsState(viewModel: self, option: .settings)
        let leaderboardState = MenuLeaderboardState(viewModel: self, option: .leaderboard)
        
        self.stateMachine = GKStateMachine(states: [playState, settingsState, leaderboardState])
        self.stateMachine.enter(MenuPlayState.self)
    }
    
    func navigateDown() {
        switch stateMachine.currentState {
        case is MenuPlayState:
            stateMachine.enter(MenuSettingsState.self)
        case is MenuSettingsState:
            stateMachine.enter(MenuLeaderboardState.self)
        default:
            break // Já está no último, não faz nada
        }
    }
    
    func navigateUp() {
        switch stateMachine.currentState {
        case is MenuLeaderboardState:
            stateMachine.enter(MenuSettingsState.self)
        case is MenuSettingsState:
            stateMachine.enter(MenuPlayState.self)
        default:
            break // Já está no primeiro, não faz nada
        }
    }
    
    func selectCurrentOption() {
        switch selectedOption {
        case .play:
            onPlay()
        case .settings:
            onSettings()
        case .leaderboard:
            onLeaderboard()
        }
    }
}
