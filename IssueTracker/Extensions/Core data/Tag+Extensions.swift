//
//  Tag+Extensions.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import CoreData
import SwiftUI

extension Tag {
    convenience init(name: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = name
    }
    
    convenience init(name: String, colour: Color, context: NSManagedObjectContext) {
        self.init(name: name, context: context)
        self.colour = colour.hexValue
        let opacity = colour.opacityValue
        self.opacity = opacity
    }
    
    public override func awakeFromInsert() {
        self.dateCreated = .now
        self.id = UUID()
    }
}

// MARK: Properties
extension Tag {
    var wrappedDateCreated: Date {
        get { self.dateCreated ?? .now }
        set { self.dateCreated = newValue }
    }
    
    var wrappedColour: String {
        get { self.colour ?? "0000FF" }
        set { self.colour = newValue }
    }
    
    public var wrappedId: UUID {
        get { self.id ?? UUID() }
        set { self.id = newValue }
    }
    
    var wrappedName: String {
        get { self.name ?? "N/A" }
        set { self.name = newValue }
    }
    
    var wrappedOpacity: Double {
        get { self.opacity }
        set { self.opacity = newValue }
    }
}
