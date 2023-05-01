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
    enum Status: String, CaseIterable, Identifiable, CustomStringConvertible {
        case open
        case closed
        
        var id: Self { self }
        
        var label: LocalizedStringKey {
            switch self {
            case .closed: return "Closed"
            case .open: return "Open"
            }
        }
        
        var description: String {
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
    
    var wrappedComments: [Comment] {
        get { self.comments?.allObjects as? [Comment] ?? [] }
        set { self.comments = NSSet(array: newValue) }
    }
    
    var wrappedTags: Set<Tag> {
        get { self.tags as? Set<Tag> ?? [] }
        set { self.tags = NSSet(set: newValue) }
    }
    
    var sortedComments: [Comment] {
        wrappedComments.sorted { $0.wrappedDateCreated < $1.wrappedDateCreated }
    }
}

// MARK: - Functions
extension Issue {
    /// Copies the properties of the given issue to self.
    /// - Parameter issue: The issue to copy properties from.
    func copyProperties(from issueProperties: IssueProperties) {
        self.name = issueProperties.name
        self.issueDescription = issueProperties.issueDescription
        self.tags = NSSet(set: issueProperties.tags)
        self.priority = issueProperties.priority.rawValue
    }
    
    var issueProperties: IssueProperties {
        let sortedTags = wrappedTags.sorted { $0.wrappedName < $1.wrappedName }
        return IssueProperties.init(
            name: wrappedName,
            issueDescription: wrappedIssueDescription,
            priority: wrappedPriority,
            tags: wrappedTags,
            sortedTags: sortedTags,
            dateCreated: wrappedDateCreated
        )
    }
}
