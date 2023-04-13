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
    
    var hasAttachments: Bool {
        guard let attachments else {
            return false
        }
        return attachments.count != 0
    }
    
    static func copy(source: Comment) -> Comment {
        Comment(comment: source.wrappedComment, context: source.managedObjectContext!)
    }
}

// TODO: move me to own file
extension Attachment {
    var wrappedDateCreated: Date {
        get { dateCreated ?? .now }
        set { dateCreated = newValue }
    }
    
    var wrappedId: UUID {
        get { id ?? UUID() }
        set { id = newValue }
    }
    
    static func ==(lhs: Attachment, rhs: Attachment) -> Bool {
        guard let lhsURL = lhs.assetURL, let rhsURL = rhs.assetURL else {
            return false
        }
        return lhsURL == rhsURL
    }
}
