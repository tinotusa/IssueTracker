//
//  IssuesViewModel.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import Foundation
import CoreData
import os

final class IssuesViewModel: ObservableObject {
    @Published var showingAddIssueView = false
    private let viewContext: NSManagedObjectContext
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "IssuesViewModel")
    
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
}

extension IssuesViewModel {
    /// Deletes the given issue from core data.
    /// - Parameter issue: The `Issue` to delete.
    func deleteIssue(_ issue: Issue) {
        log.debug("Deleting issue with name \"\(issue.name)\" ...")
        // TODO: either set it to some archived state or implement undo ?
        viewContext.delete(issue)
        do {
            try viewContext.save()
            log.debug("Successfully deleted issue.")
        } catch {
            log.error("Failed to delete issue. \(error)")
        }
    }
}
