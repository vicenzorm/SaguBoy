//
//  DataViewModel.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 22/09/25.
//

import Foundation
import SwiftData
import SwiftUICore

final class DataViewModel: DataViewModelProtocol {
        private var modelContext: ModelContext
        
        var score: Ponctuation?
        var scores: [Ponctuation] = []
        
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
        }
        
    func fetchScores() {
        do {
            let descriptor = FetchDescriptor<Ponctuation>(
                sortBy: [SortDescriptor(\.score, order: .reverse)]
            )
            scores = try modelContext.fetch(descriptor)
        } catch {
            print("Erro ao buscar pontuações: \(error.localizedDescription)")
        }
    }
    
    func fetchBestScore() {
        do {
            var descriptor = FetchDescriptor<Ponctuation>(
                sortBy: [SortDescriptor(\.score, order: .reverse)]
            )
            descriptor.fetchLimit = 1
            scores = try modelContext.fetch(descriptor)
        } catch {
            print("Erro ao buscar melhor pontuação: \(error.localizedDescription)")
        }
    }
  func addScore(value: Int) {
        let newScore = Ponctuation(score: value)
        modelContext.insert(newScore)
        do {
            try modelContext.save()
        } catch {
            print("nao foi possivel salvar a pontuacao")
        }
    }
}
