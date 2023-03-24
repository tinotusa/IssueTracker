//
//  Tag+Example.swift
//  IssueTracker
//
//  Created by Tino on 23/3/2023.
//

import Foundation

extension Tag {
    static var example: Tag {
        let viewContext = PersistenceController.preview.container.viewContext
        let fetchRequest = fetchRequest()
        do {
            let results = try viewContext.fetch(fetchRequest)
            guard let tag = results.first else {
                fatalError("Failed to get example tag. No tags found.")
            }
            return tag
        } catch {
            fatalError("Failed to get example tag. \(error)")
        }
    }
}
