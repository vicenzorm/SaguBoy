//
//  MenuState.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 23/09/25.
//

import GameplayKit

class MenuState: GKState {
    unowned var viewModel: MenuViewModel
    var option: MenuOption

    init(viewModel: MenuViewModel, option: MenuOption) {
        self.viewModel = viewModel
        self.option = option
        super.init()
    }

    override func didEnter(from previousState: GKState?) {
        // Envolvemos a mutação em um bloco para ser executado na thread principal.
        DispatchQueue.main.async {
            self.viewModel.selectedOption = self.option
        }
    }
}
