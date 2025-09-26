//
//  TronquinhoState.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 24/09/25.
//

import Foundation
import GameplayKit
import SpriteKit

class TronquinhoState: GKState {
    unowned var tronco: TroncoNode

    init(tronco: TroncoNode) {
        self.tronco = tronco
        super.init()
    }
}
