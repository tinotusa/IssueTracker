//
//  Comment+Example.swift
//  IssueTracker
//
//  Created by Tino on 23/3/2023.
//

import Foundation

extension Comment {
    static var example: Comment {
        let viewContext = PersistenceController.preview.container.viewContext
        let fetchRequest = fetchRequest()
        do {
            let results = try viewContext.fetch(fetchRequest)
            guard let comment = results.first else {
                fatalError("Failed to get example comment. No comments found.")
            }
            return comment
        } catch {
            fatalError("Failed to get comment. \(error)")
        }
    }
}
