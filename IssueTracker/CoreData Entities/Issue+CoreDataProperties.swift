//
//  Issue+CoreDataProperties.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//
//

import Foundation
import CoreData


extension Issue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Issue> {
        return NSFetchRequest<Issue>(entityName: "Issue")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var issueDescription: String?
    @NSManaged public var name: String?
    @NSManaged public var priority: Int16
    @NSManaged public var status: String?
    @NSManaged public var comments: NSOrderedSet?
    @NSManaged public var project: Project?
    @NSManaged public var tags: NSOrderedSet?

}

// MARK: Generated accessors for comments
extension Issue {

    @objc(insertObject:inCommentsAtIndex:)
    @NSManaged public func insertIntoComments(_ value: Comment, at idx: Int)

    @objc(removeObjectFromCommentsAtIndex:)
    @NSManaged public func removeFromComments(at idx: Int)

    @objc(insertComments:atIndexes:)
    @NSManaged public func insertIntoComments(_ values: [Comment], at indexes: NSIndexSet)

    @objc(removeCommentsAtIndexes:)
    @NSManaged public func removeFromComments(at indexes: NSIndexSet)

    @objc(replaceObjectInCommentsAtIndex:withObject:)
    @NSManaged public func replaceComments(at idx: Int, with value: Comment)

    @objc(replaceCommentsAtIndexes:withComments:)
    @NSManaged public func replaceComments(at indexes: NSIndexSet, with values: [Comment])

    @objc(addCommentsObject:)
    @NSManaged public func addToComments(_ value: Comment)

    @objc(removeCommentsObject:)
    @NSManaged public func removeFromComments(_ value: Comment)

    @objc(addComments:)
    @NSManaged public func addToComments(_ values: NSOrderedSet)

    @objc(removeComments:)
    @NSManaged public func removeFromComments(_ values: NSOrderedSet)

}

// MARK: Generated accessors for tags
extension Issue {

    @objc(insertObject:inTagsAtIndex:)
    @NSManaged public func insertIntoTags(_ value: Tag, at idx: Int)

    @objc(removeObjectFromTagsAtIndex:)
    @NSManaged public func removeFromTags(at idx: Int)

    @objc(insertTags:atIndexes:)
    @NSManaged public func insertIntoTags(_ values: [Tag], at indexes: NSIndexSet)

    @objc(removeTagsAtIndexes:)
    @NSManaged public func removeFromTags(at indexes: NSIndexSet)

    @objc(replaceObjectInTagsAtIndex:withObject:)
    @NSManaged public func replaceTags(at idx: Int, with value: Tag)

    @objc(replaceTagsAtIndexes:withTags:)
    @NSManaged public func replaceTags(at indexes: NSIndexSet, with values: [Tag])

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSOrderedSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSOrderedSet)

}

extension Issue : Identifiable {

}
