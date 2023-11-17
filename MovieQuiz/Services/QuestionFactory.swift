//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Максим Петров on 14.11.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveQuestion (_ question: QuizQuestion)
}
protocol QuestionFactory {
    func requestNextQuestion()
}

final class QuestionFactoryImpl {
    // MARK: - Proreties
    private weak var delegate: QuestionFactoryDelegate?
    
    // MARK: - Init
    init(delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
    }
}

extension QuestionFactoryImpl: QuestionFactory{
        func requestNextQuestion() {
            guard let question = questions.randomElement() else {
                assertionFailure("question is empty")
                return
            }
            delegate?.didReceiveQuestion(question)
        }
    }


private let questions: [QuizQuestion] = [
    QuizQuestion(
        image         : "The Godfather",
        text          : "Рейтинг этого фильма больше чем 9?",
        correctAnswer : true),
    QuizQuestion(
        image         : "The Dark Knight",
        text          : "Рейтинг этого фильма больше чем 8?",
        correctAnswer : true),
    QuizQuestion(
        image         : "Kill Bill",
        text          : "Рейтинг этого фильма больше чем 8,5?",
        correctAnswer : false),
    QuizQuestion(
        image         : "The Avengers",
        text          : "Рейтинг этого фильма больше чем 8?",
        correctAnswer : false),
    QuizQuestion(
        image         : "Deadpool",
        text          : "Рейтинг этого фильма больше чем 7,5?",
        correctAnswer : true),
    QuizQuestion(
        image         : "The Green Knight",
        text          : "Рейтинг этого фильма больше чем 7?",
        correctAnswer : false),
    QuizQuestion(
        image         : "Old",
        text          : "Рейтинг этого фильма больше чем 6?",
        correctAnswer : false),
    QuizQuestion(
        image         : "The Ice Age Adventures of Buck Wild",
        text          : "Рейтинг этого фильма больше чем 6?",
        correctAnswer : false),
    QuizQuestion(
        image         : "Tesla",
        text          : "Рейтинг этого фильма больше чем 6?",
        correctAnswer : false),
    QuizQuestion(
        image         : "Vivarium",
        text          : "Рейтинг этого фильма больше чем 6?",
        correctAnswer : false)
]