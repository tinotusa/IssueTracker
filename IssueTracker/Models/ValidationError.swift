//
//  ValidationError.swift
//  IssueTracker
//
//  Created by Tino on 20/4/2023.
//

import Foundation

enum ValidationError: LocalizedError {
    case invalidInput(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidInput(let message): return message
        }
    }
}
