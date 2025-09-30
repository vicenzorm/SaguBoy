//
//  MenuButton.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 30/09/25.
//

import SwiftUI

struct MenuButton: View {
    @Binding var isSelected: Bool
    let buttonName: String
    let onTapped: () -> Void
    
    var body: some View {
        ZStack {
            Image(isSelected ? .menuSelectedBackground : .menuNSelectedBackground)
                .resizable()
                .frame(width: 125, height: 29)
            
            HStack {
                Text(buttonName)
                    .font(.custom("determination", size: 13))
            }
            .padding(8)
            .frame(width: 125, height: 29)
        }
        .onTapGesture {
            onTapped()
        }
    }
}

#Preview {
    MenuButton(isSelected: .constant(true), buttonName: "PLAY") {
        
    }
}
