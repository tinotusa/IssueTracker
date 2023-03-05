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
    var comment: String {
        get { self.comment_ ?? "N/A" }
        set { self.comment_ = newValue }
    }
    
    public var id: UUID {
        get { self.id_ ?? UUID() }
        set { self.id_ = newValue }
    }
    
    var dateCreated: Date {
        get { self.dateCreated_ ?? .now }
        set { self.dateCreated_ = newValue }
    }
    
    var wrappedAttachments: [Attachment] {
        attachments?.allObjects as? [Attachment] ?? []
    }
}
