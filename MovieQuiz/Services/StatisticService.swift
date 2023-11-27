//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Максим Петров on 14.11.2023.
//

import Foundation

protocol StatisticService{
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: bestGame? { get }
    
    func store(correct: Int, total: Int)
}

final class StatisticServiceImpl {
    
    private enum Keys: String {
        case total, correct, bestGame, gamesCount
    }
    
    private let userDefaults: UserDefaults
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let dateProvider: () -> Date
    
    // MARK: -init
    init(userDefaults: UserDefaults = .standard,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder(),
         dateProvider: @escaping () -> Date = { Date() }
    ){
        self.userDefaults = userDefaults
        self.decoder = decoder
        self.encoder = encoder
        self.dateProvider = dateProvider
    }
}

extension StatisticServiceImpl: StatisticService {
    
    var gamesCount: Int{
        get{
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set{
            userDefaults.setValue(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var total: Int{
        get{
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set{
            userDefaults.setValue(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var correct: Int{
        get{
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set{
            userDefaults.setValue(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var bestGame: bestGame? {
        get {
            guard
                let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let bestGame = try? decoder.decode(MovieQuiz.bestGame.self, from: data) else{
                return nil
            }
            return bestGame
        }
        set{
            let data = try? encoder.encode(newValue)
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    var totalAccuracy: Double{
        Double(correct) / Double(total) * 100
    }
    
    func store(correct: Int, total: Int) {
        self.correct += correct
        self.total += total
        self.gamesCount += 1
        
        let date = dateProvider()
        let currentBestGame = MovieQuiz.bestGame(correct: correct, total: total, date: date)
        
        if let previousBestGame = bestGame{
            if currentBestGame > previousBestGame{
                bestGame = currentBestGame
            }
        }else{
            bestGame = currentBestGame
        }
        
    }
}
