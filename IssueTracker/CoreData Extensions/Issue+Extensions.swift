//
//  Issue+Extensions.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import Foundation
import CoreData
import SwiftUI

extension Issue {
    convenience init(
        name: String,
        issueDescription: String,
        priority: Priority,
        tags: Set<Tag>,
        context: NSManagedObjectContext
    ) {
        self.init(context: context)
        self.name = name
        self.issueDescription = issueDescription
        self.priority = priority.rawValue
        self.addToTags(NSSet(set: tags))
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
        self.dateCreated = .now
        self.wrappedStatus = .open
    }
}

// MARK: Enums
extension Issue {
    /// The priority level of the issue.
    enum Priority: Int16, CaseIterable, Identifiable {
        case low
        case medium
        case high
        
        var id: Self { self }
        
        var title: LocalizedStringKey {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
    }
    
    /// The status of the issue.
    enum Status: String, CaseIterable, Identifiable {
        case open
        case closed
        
        var id: Self { self }
        
        var label: LocalizedStringKey {
            switch self {
            case .closed: return "Closed"
            case .open: return "Open"
            }
        }
    }
    
}

// MARK: Properties
extension Issue {
    public var wrappedId: UUID {
        get { self.id ?? UUID() }
        set { self.id = newValue }
    }
    
    var wrappedDateCreated: Date {
        get { self.dateCreated ?? .now }
        set { self.dateCreated = newValue }
    }
    
    var wrappedIssueDescription: String {
        get { self.issueDescription ?? "N/A" }
        set { self.issueDescription = newValue }
    }
    
    var wrappedName: String {
        get { self.name ?? "N/A" }
        set { self.name = newValue }
    }
    
    var wrappedPriority: Priority {
        get { Priority(rawValue: self.priority) ?? Priority.low }
        set { self.priority = newValue.rawValue }
    }
    
    var wrappedStatus: Status {
        get {
            if let status = status {
                return Status(rawValue: status) ?? Status.open
            }
            return Status.open
        }
        set { self.status = newValue.rawValue }
    }
    
    var wrappedComments: [Comment] {
        get { self.comments?.allObjects as? [Comment] ?? [] }
        set { self.comments = NSSet(array: newValue) }
    }
    
    /// A boolean value indicating whether the issue's status is open.
    var isOpenStatus: Bool {
        guard let status, let status = Status(rawValue: status), status == .open else {
            return false
        }
        return status == .open
    }
    
    
}

// MARK: - Functions
extension Issue {
    /// Copies the properties of the given issue to self.
    /// - Parameter issue: The issue to copy properties from.
    func copyProperties(from issue: Issue) {
        self.name = issue.name
        self.issueDescription = issue.issueDescription
        self.tags = issue.tags
        self.priority = issue.priority
    }
    
    static var example: Issue {
        let viewContext = PersistenceController.issuesPreview.container.viewContext
        let request = fetchRequest()
        do {
            let result = try viewContext.fetch(request)
            guard let issue = result.first else {
                fatalError("Failed to get issue from issues preview.")
            }
            return issue
        } catch {
            fatalError("Failed to get issue example. \(error)")
        }
    }
}
