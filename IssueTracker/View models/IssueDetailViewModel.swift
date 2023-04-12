//
//  IssueDetailViewModel.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import Foundation
import CoreData
import os

final class IssueDetailViewModel: ObservableObject {
    private let issue: Issue
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: IssueDetailViewModel.self)
    )
    /// The comments text.
    @Published var comment = ""
    private lazy var persistenceController = PersistenceController.shared
    
    init(issue: Issue) {
        self.issue = issue
    }
}

extension IssueDetailViewModel {
    var validComment: Bool {
        let comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        if comment.isEmpty {
            return false
        }
        return true
    }
}
