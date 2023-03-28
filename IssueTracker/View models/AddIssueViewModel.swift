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
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AddIssueViewModel.self)
    )
    private lazy var persistenceController = PersistenceController.shared
}

extension AddIssueViewModel {
    var allFieldsFilled: Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !name.isEmpty
    }
    
    /// Adds an Issue entity to Core Data.
    func addIssue(to project: Project) {
        guard allFieldsFilled else {
            logger.debug("Failed to add issue. Not all fields have input.")
            return
        }
        do {
            try persistenceController.addIssue(name: name, issueDescription: description, priority: priority, tags: tags, project: project)
        } catch {
            logger.error("Failed to add issue. \(error)")
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
