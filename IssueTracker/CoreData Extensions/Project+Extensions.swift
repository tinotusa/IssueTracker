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

// MARK: - Property wrappers
extension Project {
    var name: String {
        get {
            self.name_ ?? "N/A"
        }
        set {
            self.name_ = newValue
        }
    }
    
    public var id: UUID {
        get {
            self.id_ ?? UUID()
        }
        set {
            self.id_ = newValue
        }
    }
    
    var dateCreated: Date {
        get {
            self.dateCreated_ ?? .now
        }
        set {
            self.dateCreated_ = newValue
        }
    }
    
    var startDate: Date {
        get {
            self.startDate_ ?? .now
        }
        set {
            self.startDate_ = newValue
        }
    }
}
