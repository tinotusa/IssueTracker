//
//  PersistenceError.swift
//  IssueTracker
//
//  Created by Tino on 12/4/2023.
//

import Foundation

enum PersistenceError: Error, LocalizedError {
    case saveError
    
    var errorDescription: String? {
        switch self {
        case .saveError: return "Failed to save the changes made."
        }
    }
}
