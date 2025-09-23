//
//  MenuSettingsState.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 23/09/25.
//

import GameplayKit

class MenuSettingsState: MenuState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // De "Settings", podemos voltar para "Play" ou ir para "Leaderboard"
        return stateClass is MenuPlayState.Type || stateClass is MenuLeaderboardState.Type
    }
}
