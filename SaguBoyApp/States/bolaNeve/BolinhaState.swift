//
//  BolinhaState.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 29/09/25.
//

import Foundation
import GameplayKit
import SpriteKit

class BolinhaState: GKState {
    unowned var bola: BolaNode

    init(bola: BolaNode) {
        self.bola = bola
        super.init()
    }
}
