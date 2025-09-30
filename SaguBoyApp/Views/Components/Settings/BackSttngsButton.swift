//
//  BackSttngsButton.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 30/09/25.
//

import SwiftUI

struct BackSttngsButton: View {
    
    @Binding var isSelected: Bool
    let buttonName: String
    let onTapped: () -> Void
    
    
    var body: some View {
        ZStack {
            Image(isSelected ? .sttngsSelectedBackground : .sttngsNSelectedBackground)
                .resizable()
                .frame(width: 125, height: 29)
            VStack {
                
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
    BackSttngsButton(isSelected: .constant(true), buttonName: "BACK TO MENU") {
        
    }
}
