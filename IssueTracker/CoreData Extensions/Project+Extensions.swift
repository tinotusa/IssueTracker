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
        self.name = name.filterWhitespace()
        self.startDate = startDate
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
        self.dateCreated = .now
    }
    
    /// The latest issue added to the project.
    var latestIssue: Issue? {
        let issues = self.issues?.allObjects as? [Issue] ?? []
        let sortedIssues = issues.sorted { $0.wrappedDateCreated > $1.wrappedDateCreated }
        return sortedIssues.last
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
    var wrappedName: String {
        get {
            self.name ?? "N/A"
        }
        set {
            self.name = newValue
        }
    }
    
    public var wrappedId: UUID {
        get {
            self.id ?? UUID()
        }
        set {
            self.id = newValue
        }
    }
    
    var wrappedDateCreated: Date {
        get {
            self.dateCreated ?? .now
        }
        set {
            self.dateCreated = newValue
        }
    }
    
    var wrappedStartDate: Date {
        get {
            self.startDate ?? .now
        }
        set {
            self.startDate = newValue
        }
    }
}
