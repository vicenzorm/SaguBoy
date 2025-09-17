//
//  PlayerState.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 17/09/25.
//

import Foundation
import GameplayKit
import SpriteKit

class PlayerState: GKState {
    unowned var player: PlayerNode

    init(player: PlayerNode) {
        self.player = player
        super.init()
    }
}
