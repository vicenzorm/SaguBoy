//
//  MenuLeaderboardState.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 23/09/25.
//

import GameplayKit

class MenuLeaderboardState: MenuState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // De "Leaderboard", só podemos voltar para "Settings"
        return stateClass is MenuSettingsState.Type
    }
}
