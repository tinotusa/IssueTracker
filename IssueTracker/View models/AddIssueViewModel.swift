//
//  AddIssueViewModel.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import Foundation
import os
import CoreData

final class AddIssueViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var priority: Issue.Priority = .low
    @Published var tags: Set<Tag> = []
    @Published var newTag = ""
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "AddIssueViewModel")
    private let viewContext: NSManagedObjectContext
    private let project: Project
    
    init(project: Project, viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
        self.project = project
    }
}

extension AddIssueViewModel {
    var allFieldsFilled: Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }
    
    /// Adds an Issue entity to Core Data.
    func addIssue() {
        log.debug("Adding issue to core data...")
        guard allFieldsFilled else {
            log.debug("Failed to add issue. Not all fields have input.")
            return
        }
        let issue = Issue(
            name: name,
            issueDescription: description,
            priority: priority,
            tags: tags,
            context: viewContext
        )
        project.addToIssues(issue)
        
        do {
            try viewContext.save()
            log.debug("Successfully saved issue to core data.")
        } catch {
            log.error("Failed to save issue to disk. \(error)")
        }
    }
    
    /// Adds the given tag to the set of tags.
    ///
    /// If the tag already exists in the set it is removed.
    ///
    /// - Parameter tag: The tag to insert.
    func addTag(_ tag: Tag) {
        if tags.contains(tag) {
            tags.remove(tag)
        } else {
            tags.insert(tag)
        }
    }
}
