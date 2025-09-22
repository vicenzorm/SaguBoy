//
//  Ponctuation.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 22/09/25.
//
import SwiftData
import Foundation

@Model
final class Ponctuation {
    var id = UUID()
    var score: Int
    
    init(score: Int) {
        self.score = score
    }
}
