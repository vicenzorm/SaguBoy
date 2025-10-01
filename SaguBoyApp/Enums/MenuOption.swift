//
//  MenuOption.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 23/09/25.
//

import Foundation

enum MenuOption: CaseIterable {
    case play
    case settings
    case leaderboard
}

extension MenuOption {
   func assetName(selected: Bool) -> String {
       switch self {
       case .play:        return selected ? "menuPlaySelected"        : "menuPlayUnselected"
       case .settings:    return selected ? "menuSettingsSelected"    : "menuSettingsUnselected"
       case .leaderboard: return selected ? "menuLeaderboardSelected" : "menuLeaderboardUnselected"
       }
   }
}
