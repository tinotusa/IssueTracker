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
    
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
}

extension AddIssueViewModel {
    var allFieldsFilled: Bool {
        false
    }
    
    func addIssue() {
        guard allFieldsFilled else {
            return
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
