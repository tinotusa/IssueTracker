//
//  PersistenceError.swift
//  IssueTracker
//
//  Created by Tino on 12/4/2023.
//

import Foundation

enum PersistenceError: Error, LocalizedError {
    case saveError
    case noICloudAccount
    
    var errorDescription: String? {
        switch self {
        case .saveError: return "Failed to save the changes made."
        case .noICloudAccount: return "No iCloud account."
        }
    }
}
