//
//  SplashScreenView.swift
//  SaguBoyApp
//
//  Created by Bernardo Garcia Fensterseifer on 26/09/25.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            GIFView(gifName: "backgroundGIF")
                .edgesIgnoringSafeArea(.all)
        }
    }
}
