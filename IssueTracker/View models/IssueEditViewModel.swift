//
//  IssueEditViewModel.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import Foundation
import CoreData

final class IssueEditViewModel: ObservableObject {
    @Published var issueCopy: Issue
    
    init(issue: Issue, viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        issueCopy = Issue(
            name: issue.name,
            issueDescription: issue.description,
            priority: issue.priority,
            tags: issue.tags?.set as! Set<Tag>,
            context: issue.managedObjectContext!
        )
    }
}

extension IssueEditViewModel {
    func saveChanges() {
        
    }
}
