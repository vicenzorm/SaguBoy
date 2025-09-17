//
//  PhysicsCategory.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 15/09/25.
//

import Foundation

enum PhysicsCategory {
    static let none: UInt32   = 0
    static let player: UInt32 = 1 << 0 // 0001
    static let enemy:  UInt32 = 1 << 1 // 0010
    static let powerup: UInt32 = 1 << 2
    static let wind: UInt32 = 1 << 3
}
