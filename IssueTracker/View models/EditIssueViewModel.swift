//
//  EditIssueViewModel.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import Foundation
import CoreData
import os

final class EditIssueViewModel: ObservableObject {
    /// A copy of the issue being edited.
    @Published var issueCopy: Issue
    /// A set of the tags the user has selected when editing.
    @Published var selectedTags: Set<Tag> = []
    /// The issue being edited.
    private var issue: Issue
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: EditIssueViewModel.self)
    )
    private lazy var persistenceController = PersistenceController.shared
    /// Creates a new EditIssueViewModel
    /// - Parameters:
    ///   - issue: The issue being edited.
    init(issue: Issue) {
        self.issue = issue
        issueCopy = Issue.copyIssue(issue: issue)
        self.selectedTags = issue.wrappedTags
    }
}

extension EditIssueViewModel {
    /// A boolean value indicating that changes have been made.
    var hasChanges: Bool {
        guard let issueTags = issue.tags else {
            return false
        }
        // check that all the tags selected are equal to the original tags.
        // if they are not the same a change has been made.
        let allTagsAreEqual = selectedTags.allSatisfy { issueTags.contains($0) }
        return (
            issue.name != issueCopy.name ||
            issue.issueDescription != issueCopy.issueDescription ||
            issue.priority != issueCopy.priority ||
            issueTags.count != selectedTags.count ||
            !allTagsAreEqual
        )
    }
    
    /// Saves the changes made to core data.
    func saveChanges() {
        logger.debug("Saving issue changes ...")
        if !hasChanges {
            logger.debug("Failed to save changes. No changes have been made.")
            return
        }
        do {
            try persistenceController.copyIssue(from: issueCopy, to: issue, withTags: selectedTags)
        } catch {
            logger.error("Failed to save changes. \(error)")
        }
    }
}
