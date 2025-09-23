//
//  MenuPlayState.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 23/09/25.
//

import GameplayKit

class MenuPlayState: MenuState {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        // Do estado "Play", só podemos ir para "Settings"
        return stateClass is MenuSettingsState.Type
    }
}
