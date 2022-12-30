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
    private let viewContext: NSManagedObjectContext
    private let issue: Issue
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "IssueDetailViewModel")
    
    init(issue: Issue, viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
        self.issue = issue
    }
    
    func addNewEmptyComment() {
        log.debug("Add new empty comment...")
        let comment = Comment(context: viewContext)
        comment.id = UUID()
        comment.issue = issue
        comment.dateCreated = Date()
        do {
            try viewContext.save()
            log.debug("Successfully added a new empty comment.")
        } catch {
            log.error("Failed to add new empty comment.")
        }
    }
}
