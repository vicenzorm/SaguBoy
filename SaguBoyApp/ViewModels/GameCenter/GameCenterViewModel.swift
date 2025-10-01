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
    
    private var isAuthReady: Bool = false
    private var player: GKLocalPlayer?
    private var showAuthSheet: Bool = false
    static var achievementsStatus: [String: Bool] = ["beginner_climber": false, "professional_climber": false, "goat_climber": false]
    static var achievementsProgress: [String: Double] = ["beginner_climber": 0.0, "professional_climber": 0.0, "goat_climber": 0.0]
    
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
    
    @objc private func playerAuthDidChange() {
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
                print("enviou pont \(score)")
            } catch {
                print("erro quando envia pontuação\(error.localizedDescription)")
            }
        } else {
            print("não autenticado")
            return
        }
    }
    
    static func reportAchievement(id: String, percent: Double, showsBanner: Bool = true) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        
        GKAchievement.loadAchievements { existing, error in
            
            if let error { print("loadAchievements:", error); return }
            
            let current = existing?.first(where: {$0.identifier == id})
            let achievement = current ?? GKAchievement(identifier: id)
            
            let newPercent = max(achievement.percentComplete, percent)
            guard newPercent < 100 || achievement.isCompleted == false else { return }
            
            achievement.percentComplete = min(newPercent, 100)
            achievement.showsCompletionBanner = showsBanner
            
//            achievementSta.formIndex(after: &achievementsStatus.startIndex)
            
            GKAchievement.report([achievement]) { error in
                if let error { print("reportAchievement:", error)}
            }
            
            
        }
    }
    
}
