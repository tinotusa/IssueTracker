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
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "IssueEditViewModel")
    private let viewContext: NSManagedObjectContext
    
    /// Creates a new EditIssueViewModel
    /// - Parameters:
    ///   - issue: The issue being edited.
    ///   - viewContext: The managed object context for the issue.
    init(issue: Issue, viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.issue = issue
        self.viewContext = viewContext
        issueCopy = Issue(
            name: issue.name,
            issueDescription: issue.issueDescription,
            priority: issue.priority,
            tags: issue.tags?.set as? Set<Tag> ?? [],
            context: issue.managedObjectContext!
        )
        self.selectedTags = issue.tags?.set as? Set<Tag> ?? []
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
        log.debug("Saving issue changes ...")
        if !hasChanges {
            log.debug("Failed to save changes. No changes have been made.")
            return
        }
        issue.copyProperties(from: issueCopy) // does this copy the stuff
        issue.tags = NSOrderedSet(set: selectedTags)
        do {
            try viewContext.save()
            log.debug("Successfully saved issue changes")
        } catch {
            log.error("Failed to save issue changes. \(error)")
        }
    }
}
