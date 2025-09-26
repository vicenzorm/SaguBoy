//
//  DataViewModel.swift
//  SaguBoyApp
//
//  Created by Vicenzo Másera on 22/09/25.
//

import Foundation
import SwiftData
import SwiftUICore
import Observation

@Observable
final class DataViewModel {
    private var modelContext: ModelContext
    
    var score: Ponctuation?
    var scores: [Ponctuation] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchScores(limit: Int? = nil) {
        do {
            var descriptor = FetchDescriptor<Ponctuation>(
                sortBy: [SortDescriptor(\.score, order: .reverse)]
            )
            if let limit = limit {
                descriptor.fetchLimit = limit
            }
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
            print ("salvou a pontuacao")
            try modelContext.save()
        } catch {
            print("nao foi possivel salvar a pontuacao")
        }
    }
}
