//
//  Enemy.swift
//  SaguBoyGame
//
//  Created by Vicenzo Másera on 08/09/25.
//

import Foundation

struct Enemy: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
}
