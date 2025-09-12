//
//  GameCenterView.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 12/09/25.
//

import Foundation
import SwiftUI
import GameKit

struct GameCenterView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = GKGameCenterViewController(state: .default)
        return viewController
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
