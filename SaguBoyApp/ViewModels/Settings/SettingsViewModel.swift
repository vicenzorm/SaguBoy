//  SettingsViewModel.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 24/09/25.
//

import Foundation
import GameplayKit
import Observation

@Observable
@MainActor
class SettingsViewModel {
    
    var selectedOption: SettingsOption = .sounds
    private var stateMachine: GKStateMachine!
    
    var onBack: () -> Void = {}

    init() {
        let soundsState = SettingsSoundsState(viewModel: self, option: .sounds)
        let hapticsState = SettingsHapticsState(viewModel: self, option: .haptics)
        let backState = SettingsBackState(viewModel: self, option: .back)
        
        self.stateMachine = GKStateMachine(states: [soundsState, hapticsState, backState])
        self.stateMachine.enter(SettingsSoundsState.self)
    }
    
    func navigateDown() {
        switch stateMachine.currentState {
        case is SettingsSoundsState:
            stateMachine.enter(SettingsHapticsState.self)
        case is SettingsHapticsState:
            stateMachine.enter(SettingsBackState.self)
        case is SettingsBackState:
            stateMachine.enter(SettingsSoundsState.self)
        default:
            break
        }
    }
    
    func navigateUp() {
        switch stateMachine.currentState {
        case is SettingsSoundsState:
            stateMachine.enter(SettingsBackState.self)
        case is SettingsHapticsState:
            stateMachine.enter(SettingsSoundsState.self)
        case is SettingsBackState:
            stateMachine.enter(SettingsHapticsState.self)
        default:
            break
        }
    }
    
    func toggleSelectedOption() {
        switch selectedOption {
        case .sounds:
            SettingsManager.shared.isSoundEnabled.toggle()
        case .haptics:
            SettingsManager.shared.isHapticsEnabled.toggle()
        case .back:
            onBack()
        }
    }
}
