//
//  Comment+Extensions.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import Foundation
import CoreData

extension Comment {
    convenience init(comment: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.comment = comment
    }
    
    public override func awakeFromInsert() {
        self.id = UUID()
        self.dateCreated = .now
    }
}

// MARK: Wrapped properties
extension Comment {
    var wrappedComment: String {
        get { self.comment ?? "N/A" }
        set { self.comment = newValue }
    }
    
    public var wrappedId: UUID {
        get { self.id ?? UUID() }
        set { self.id = newValue }
    }
    
    var wrappedDateCreated: Date {
        get { self.dateCreated ?? .now }
        set { self.dateCreated = newValue }
    }
    
    var wrappedAttachments: [Attachment] {
        attachments?.allObjects as? [Attachment] ?? []
    }
    
    var sortedAttachments: [Attachment] {
        wrappedAttachments.sorted { $0.wrappedDateCreated < $1.wrappedDateCreated }
    }
}

// TODO: move me to own file
extension Attachment {
    var wrappedDateCreated: Date {
        get { dateCreated ?? .now }
        set { dateCreated = newValue }
    }
}
