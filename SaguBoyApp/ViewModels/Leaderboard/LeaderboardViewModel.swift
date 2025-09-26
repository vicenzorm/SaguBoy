//
//  LeaderboardViewModel.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 25/09/25.
//

import Foundation
import GameplayKit

@Observable
@MainActor
class LeaderboardViewModel {
    
    var selectedOption: LeaderboardOption = .back
    private var stateMachine: GKStateMachine!
    
    var onBack: () -> Void = {}
    
    init() {
        let backState = LeaderboardState(viewModel: self, option: .back)
        
        self.stateMachine = GKStateMachine(states: [backState])
        self.stateMachine.enter(LeaderboardBackState.self)
    }
}
