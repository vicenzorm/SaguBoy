//
//  SettingsButton.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 30/09/25.
//

import SwiftUI

struct SettingsButton: View {
    
    @Binding var isSelected: Bool
    @Binding var isOn: Bool
    let buttonName: String
    let onTapped: () -> Void
    
    var body: some View {
        ZStack {
            Image(isSelected ? .sttngsSelectedBackground : .sttngsNSelectedBackground)
                .resizable()
                .frame(width: 125, height: 29)
            
            HStack {
                Text(buttonName)
                    .font(.custom("determination", size: 13))
                
                Spacer()
                
                Image(isOn ? .sttngsButtonOn : .sttngsButtonOff)
                    .resizable()
                    .frame(width: 24, height: 13)
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
    SettingsButton(isSelected: .constant(true), isOn: .constant(true), buttonName: "SOUNDS") {
        print("hey hey")
    }
}
