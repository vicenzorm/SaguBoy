//
//  SettingsManager.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 24/09/25.
//

import Foundation

@Observable
class SettingsManager {
    
    static let shared = SettingsManager()
    
    private let soundKey = "isSoundEnabled"
    private let hapticsKey = "isHapticsEnabled"
    
    var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: soundKey)
        }
    }
    
    var isHapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticsEnabled, forKey: hapticsKey)
        }
    }
    
    private init() {
        self.isSoundEnabled = UserDefaults.standard.object(forKey: soundKey) as? Bool ?? true
        self.isHapticsEnabled = UserDefaults.standard.object(forKey: hapticsKey) as? Bool ?? true
    }
}
