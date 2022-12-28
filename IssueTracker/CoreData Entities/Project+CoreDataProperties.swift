//
//  Project+CoreDataProperties.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//
//

import Foundation
import CoreData


extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var issues: NSOrderedSet?

}

// MARK: Generated accessors for issues
extension Project {

    @objc(insertObject:inIssuesAtIndex:)
    @NSManaged public func insertIntoIssues(_ value: Issue, at idx: Int)

    @objc(removeObjectFromIssuesAtIndex:)
    @NSManaged public func removeFromIssues(at idx: Int)

    @objc(insertIssues:atIndexes:)
    @NSManaged public func insertIntoIssues(_ values: [Issue], at indexes: NSIndexSet)

    @objc(removeIssuesAtIndexes:)
    @NSManaged public func removeFromIssues(at indexes: NSIndexSet)

    @objc(replaceObjectInIssuesAtIndex:withObject:)
    @NSManaged public func replaceIssues(at idx: Int, with value: Issue)

    @objc(replaceIssuesAtIndexes:withIssues:)
    @NSManaged public func replaceIssues(at indexes: NSIndexSet, with values: [Issue])

    @objc(addIssuesObject:)
    @NSManaged public func addToIssues(_ value: Issue)

    @objc(removeIssuesObject:)
    @NSManaged public func removeFromIssues(_ value: Issue)

    @objc(addIssues:)
    @NSManaged public func addToIssues(_ values: NSOrderedSet)

    @objc(removeIssues:)
    @NSManaged public func removeFromIssues(_ values: NSOrderedSet)

}

extension Project : Identifiable {

}
