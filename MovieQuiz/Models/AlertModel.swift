//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Максим Петров on 15.11.2023.
//

import Foundation


struct AlertModel {
    let title: String
    let message: String
    let buttonText:String
    let buttonAction: () -> Void
}
