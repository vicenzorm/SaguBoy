//
//  ContentView.swift
//  POC-GameplayKit
//
//  Created by Vicenzo Másera on 03/09/25.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        NavigationStack {
            NavigationLink(destination: GameView()) {
                Text("Start Game")
                    .font(.title2)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
}

#Preview {
    MenuView()
}
