//
//  GameCenterViewModel.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 12/09/25.
//
import GameKit
import Foundation

@MainActor
class GameCenterViewModel {
    
    var isAuthReady: Bool = false
    var player: GKLocalPlayer?
    var showAuthSheet: Bool = false
    
    private var localPlayer: GKLocalPlayer {
        return GKLocalPlayer.local
    }
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerAuthDidChange),
            name: .GKPlayerAuthenticationDidChangeNotificationName,
            object: nil
        )
    }
    
    func authPlayer() {
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }
            
            if let vc = viewController {
                self.showAuthSheet = true
                return
            }
            
            if let error {
                print("deu erro na autenticação... \(error.localizedDescription)" )
                self.isAuthReady = false
                return
            }
            
            if self.localPlayer.isAuthenticated {
                self.isAuthReady = true
                self.player = self.localPlayer
            } else {
                self.isAuthReady = false
            }
        }
    }
    
    @objc func playerAuthDidChange() {
        self.isAuthReady = self.localPlayer.isAuthenticated
        self.player = localPlayer.isAuthenticated ? localPlayer : nil
    }
    
    func submitScore(score: Int, leaderboardID: String) async {
        if self.isAuthReady {
            do {
                try await GKLeaderboard.submitScore(
                            score,
                            context: 0,
                            player: GKLocalPlayer.local,
                            leaderboardIDs: [leaderboardID]
                        )
                print("enviou pont")
            } catch {
                print("erro quando envia pontuação\(error.localizedDescription)")
            }
        } else {
            print("não autenticado")
            return
        }
    }
    
}
