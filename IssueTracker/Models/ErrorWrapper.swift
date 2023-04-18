//
//  ErrorWrapper.swift
//  IssueTracker
//
//  Created by Tino on 18/4/2023.
//

import Foundation

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: Error
    let message: String
}
