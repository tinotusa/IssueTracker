//
//  Project+Example.swift
//  IssueTracker
//
//  Created by Tino on 23/3/2023.
//

import Foundation

extension Project {
    static var example: Project {
        let viewContext = PersistenceController.projectsPreview.container.viewContext
        let fetchRequest = fetchRequest()
        do {
            let results = try viewContext.fetch(fetchRequest)
            guard let project = results.first else {
                fatalError("Failed to get project from fetch")
            }
            return project
        } catch {
            fatalError("Failed to get project from fetch. \(error)")
        }
    }
}
