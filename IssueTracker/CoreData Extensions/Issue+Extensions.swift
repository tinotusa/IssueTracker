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
        self.priority = priority
        self.addToTags(NSOrderedSet(set: tags))
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
        self.dateCreated = .now
        self.status = .open
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
    enum Status: String {
        case open
        case closed
    }
    
}

// MARK: Properties
extension Issue {
    public var id: UUID {
        get { self.id_ ?? UUID() }
        set { self.id_ = newValue }
    }
    
    var dateCreated: Date {
        get { self.dateCreated_ ?? .now }
        set { self.dateCreated_ = newValue }
    }
    
    var issueDescription: String {
        get { self.issueDescription_ ?? "N/A" }
        set { self.issueDescription_ = newValue }
    }
    
    var name: String {
        get { self.name_ ?? "N/A" }
        set { self.name_ = newValue }
    }
    
    var priority: Priority {
        get { Priority(rawValue: self.priority_) ?? Priority.low }
        set { self.priority_ = newValue.rawValue }
    }
    
    var status: Status {
        get {
            if let status = status_ {
                return Status(rawValue: status) ?? Status.open
            }
            return Status.open
        }
        set { self.status_ = newValue.rawValue }
    }
}