//
//  Issue+Example.swift
//  IssueTracker
//
//  Created by Tino on 23/3/2023.
//

import Foundation

extension Issue {
    static var example: Issue {
        let viewContext = PersistenceController.issuesPreview.container.viewContext
        let issueFetchRequest = Issue.fetchRequest()
        do {
            let results = try viewContext.fetch(issueFetchRequest)
            return results.first!
        } catch {
            fatalError("Failed to get example issue. \(error)")
        }
    }
}
