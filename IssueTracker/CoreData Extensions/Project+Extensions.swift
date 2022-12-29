//
//  Project+Extensions.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import CoreData

extension Project {
    convenience init(name: String, startDate: Date, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
        self.startDate = startDate
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
        self.dateCreated = .now
    }
    
    /// The latest issue added to the project.
    var latestIssue: Issue? {
        self.issues?.lastObject as? Issue
    }
    
    static func example(context: NSManagedObjectContext) -> Project {
        let project = Project(name: "Example", startDate: Date(), context: context)
        do {
            try context.save()
        } catch {
            print("failed to save example project. \(error)")
        }
        return project
    }
}