//
//  Tag+CoreDataProperties.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var hexColour: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var opacity: Double
    @NSManaged public var issues: NSSet?

}

// MARK: Generated accessors for issues
extension Tag {

    @objc(addIssuesObject:)
    @NSManaged public func addToIssues(_ value: Issue)

    @objc(removeIssuesObject:)
    @NSManaged public func removeFromIssues(_ value: Issue)

    @objc(addIssues:)
    @NSManaged public func addToIssues(_ values: NSSet)

    @objc(removeIssues:)
    @NSManaged public func removeFromIssues(_ values: NSSet)

}

extension Tag : Identifiable {

}
