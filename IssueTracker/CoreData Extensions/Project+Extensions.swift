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
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    
    /// Filters the given name by removing non alphanumerics and non spaces.
    /// - Parameter name: The name to filter.
    /// - Returns: The filtered name or the name unchanged.
    static func filterName(_ name: String) -> String {
        var invalidCharacters = CharacterSet.alphanumerics
        invalidCharacters.formUnion(.whitespaces)
        invalidCharacters.invert()
        let filteredValue = name.components(separatedBy: invalidCharacters).joined(separator: "")
        return filteredValue
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
