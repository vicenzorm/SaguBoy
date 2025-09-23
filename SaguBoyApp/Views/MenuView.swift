//
//  MenuView.swift
//  SaguBoyApp
//
//  Created by Enzo Tonatto on 23/09/25.
//

import SwiftUI

struct MenuView: View {
    
    @StateObject private var viewModel = MenuViewModel()
    
    // Closure para notificar a GameView que o jogo deve começar
    var onPlay: () -> Void
    
    // Estado para evitar navegação repetida ao segurar o direcional
    @State private var directionPressed: Direction? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                // Fundo e Estrutura do "Console"
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color("consoleBackground"))
                    .frame(width: 380, height: 476)
                    .shadow(radius: 8)
                
                // Tela do Jogo com fundo e opções de menu
                ZStack {
                    // Usando o GIFNode que você já tem no projeto para o fundo
                    // Precisaremos de uma wrapper para usá-lo em SwiftUI
                    GIFView(gifName: "backgroundPlaceholder")
                    
                    VStack(spacing: 15) {
                        // Logo do Jogo - usando a imagem "shiro" do seu AppIcon
                        Image("shiro")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200)
                            .padding(.bottom, 30)

                        // Opções do Menu
                        menuOptionText(for: .play)
                        menuOptionText(for: .settings)
                        menuOptionText(for: .leaderboard)
                    }
                }
                .frame(width: 364, height: 415)
                .clipped()
                .padding(.top, 8)
                .padding(.horizontal, 8)
                
                // Textos "SaguBoy" e "Color SB"
                HStack(alignment: .bottom, spacing: 4) {
                    Text("SaguBoy")
                        .font(.system(size: 16, weight: .bold))
                    Text("Color SB")
                        .font(.system(size: 8, weight: .medium))
                        .padding(.bottom, 2)
                }
                .foregroundStyle(Color("consoleText"))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.leading, 16)
                .padding(.bottom, 10)
            }
            
            Spacer()
            
            ControllersView(
                onDirection: handleDirection,
                onA: { pressed in
                    if pressed {
                        viewModel.selectCurrentOption()
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                },
                onB: { _ in /* O botão B não faz nada no menu */ },
                onStart: { pressed in
                    if pressed {
                        viewModel.selectCurrentOption()
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                }
            )
        }
        .padding(.top, 8)
        .background(Image("metalico").resizable().scaledToFill().ignoresSafeArea(.container, edges: .bottom))
        .background(Color.black)
        .onAppear {
            // Conecta a ação de "play" do ViewModel com a closure da View
            viewModel.onPlay = onPlay
        }
    }
    
    // View customizada para as opções de texto do menu
    @ViewBuilder
    private func menuOptionText(for option: MenuOption) -> some View {
        let isSelected = viewModel.selectedOption == option
        Text(String(describing: option))
            .font(Font.custom("JetBrainsMonoNL-Regular", size: 20))
            .foregroundStyle(isSelected ? .black : .white)
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(isSelected ? Color.white : Color.clear)
            )
            .animation(.bouncy(duration: 0.2), value: viewModel.selectedOption)
    }
    
    // Função para processar a entrada do direcional/analógico
    private func handleDirection(dir: Direction, pressed: Bool) {
        if pressed {
            // Evita múltiplas chamadas se o botão for mantido pressionado
            if dir == directionPressed { return }
            directionPressed = dir
            
            switch dir {
            case .up, .upLeft, .upRight:
                viewModel.navigateUp()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .down, .downLeft, .downRight:
                viewModel.navigateDown()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            default:
                break
            }
        } else {
            // Reseta o estado quando o botão é solto
            if dir == directionPressed {
                directionPressed = nil
            }
        }
    }
}
