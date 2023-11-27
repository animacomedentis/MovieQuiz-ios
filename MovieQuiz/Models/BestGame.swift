//
//  BestGame.swift
//  MovieQuiz
//
//  Created by Максим Петров on 14.11.2023.
//

import Foundation

struct bestGame: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension bestGame: Comparable{
    private var accuracy: Double{
        guard total != 0 else{
            return 0
        }
        return  Double(correct) / Double(total)
    }
    static func < (lhs: bestGame, rhs: bestGame) -> Bool {
        lhs.accuracy < rhs.accuracy
    }
}
