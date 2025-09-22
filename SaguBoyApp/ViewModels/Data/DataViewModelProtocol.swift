//
//  DataViewModelProtocol.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 22/09/25.
//

import Foundation

protocol DataViewModelProtocol {
    var score: Ponctuation? { get }
    var scores: [Ponctuation] { get }
    func addScore(value: Int)
    func fetchScores()
    func fetchBestScore()
}
