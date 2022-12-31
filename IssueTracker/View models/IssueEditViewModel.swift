//
//  IssueEditViewModel.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import Foundation
import CoreData
import os

final class IssueEditViewModel: ObservableObject {
    @Published var issueCopy: Issue
    @Published var selectedTags: Set<Tag> = []
    private var issue: Issue
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "IssueEditViewModel")
    private let viewContext: NSManagedObjectContext
    
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

extension IssueEditViewModel {
    var hasChanges: Bool {
        return (
            issue.name != issueCopy.name ||
            issue.issueDescription != issueCopy.issueDescription ||
            issue.tags != issueCopy.tags ||
            issue.priority != issueCopy.priority
        )
    }
    
    func saveChanges() {
        log.debug("Saving changes ...")
        if !hasChanges {
            log.debug("Failed to save changes. No changes have been made.")
            return
        }
        issue.copyProperties(from: issueCopy)
        do {
            try viewContext.save()
        } catch {
            log.error("Failed to save changes. \(error)")
        }
    }
}

// TODO: move to issues extensions file
extension Issue {
    func copyProperties(from issue: Issue) {
        self.name = issue.name
        self.issueDescription = issue.issueDescription
        self.tags = issue.tags
        self.priority = issue.priority
    }
}
