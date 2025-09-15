//
//  EnemyKind.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 15/09/25.
//

import CoreGraphics

enum EnemyKind {
    case round
    case box

    var assetName: String? {
        switch self {
        case .round: return nil // ex: "enemy_round"
        case .box:   return nil // ex: "enemy_box"
        }
    }

    var defaultSize: CGSize {
        switch self {
        case .round: return CGSize(width: 30, height: 30)
        case .box:   return CGSize(width: 88, height: 28)
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .round: return defaultSize.width * 0.5
        case .box:   return 8
        }
    }
}
