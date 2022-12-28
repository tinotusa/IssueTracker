//
//  Attachment+CoreDataProperties.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//
//

import Foundation
import CoreData


extension Attachment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attachment> {
        return NSFetchRequest<Attachment>(entityName: "Attachment")
    }

    @NSManaged public var dateCreated: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var type: Int16
    @NSManaged public var url: URL?
    @NSManaged public var comment: Comment?

}

extension Attachment : Identifiable {

}
