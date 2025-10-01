//
//  LeaderboardState.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 25/09/25.
//

import GameplayKit

class LeaderboardState: GKState {
    unowned var viewModel: LeaderboardViewModel
    var option: LeaderboardOption
    
    init(viewModel: LeaderboardViewModel, option: LeaderboardOption) {
        self.viewModel = viewModel
        self.option = option
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        DispatchQueue.main.async {
            self.viewModel.selectedOption = self.option
        }
    }
}
