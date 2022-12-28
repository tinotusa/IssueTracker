//
//  Comment+CoreDataProperties.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//
//

import Foundation
import CoreData


extension Comment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Comment> {
        return NSFetchRequest<Comment>(entityName: "Comment")
    }

    @NSManaged public var comment: String?
    @NSManaged public var dateCreated: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var attachments: NSOrderedSet?
    @NSManaged public var issue: Issue?

}

// MARK: Generated accessors for attachments
extension Comment {

    @objc(insertObject:inAttachmentsAtIndex:)
    @NSManaged public func insertIntoAttachments(_ value: Attachment, at idx: Int)

    @objc(removeObjectFromAttachmentsAtIndex:)
    @NSManaged public func removeFromAttachments(at idx: Int)

    @objc(insertAttachments:atIndexes:)
    @NSManaged public func insertIntoAttachments(_ values: [Attachment], at indexes: NSIndexSet)

    @objc(removeAttachmentsAtIndexes:)
    @NSManaged public func removeFromAttachments(at indexes: NSIndexSet)

    @objc(replaceObjectInAttachmentsAtIndex:withObject:)
    @NSManaged public func replaceAttachments(at idx: Int, with value: Attachment)

    @objc(replaceAttachmentsAtIndexes:withAttachments:)
    @NSManaged public func replaceAttachments(at indexes: NSIndexSet, with values: [Attachment])

    @objc(addAttachmentsObject:)
    @NSManaged public func addToAttachments(_ value: Attachment)

    @objc(removeAttachmentsObject:)
    @NSManaged public func removeFromAttachments(_ value: Attachment)

    @objc(addAttachments:)
    @NSManaged public func addToAttachments(_ values: NSOrderedSet)

    @objc(removeAttachments:)
    @NSManaged public func removeFromAttachments(_ values: NSOrderedSet)

}

extension Comment : Identifiable {

}
