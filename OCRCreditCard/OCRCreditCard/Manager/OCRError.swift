//
//  OCRError.swift
//  OCRCreditCard
//
//  Created by kyeoeol on 2023/05/06.
//

import Foundation

enum OCRError: Error {
    case faildToGetGuideSize
    case requestRecognizeText(Error)
}

extension OCRError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .faildToGetGuideSize:
            return "Faild to get guide size."
            
        case .requestRecognizeText(let error):
            return "Request recognize text: \(error.localizedDescription)"
        }
    }
}
