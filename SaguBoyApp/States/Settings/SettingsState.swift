//
//  SettingsState.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 24/09/25.
//

import GameplayKit

class SettingsState: GKState {
    unowned var viewModel: SettingsViewModel
    var option: SettingsOption

    init(viewModel: SettingsViewModel, option: SettingsOption) {
        self.viewModel = viewModel
        self.option = option
        super.init()
    }

    override func didEnter(from previousState: GKState?) {
        // Garante que a atualização da UI ocorra na thread principal
        DispatchQueue.main.async {
            self.viewModel.selectedOption = self.option
        }
    }
}
