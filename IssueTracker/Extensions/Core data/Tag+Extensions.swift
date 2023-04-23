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
    #if os(macOS)
    convenience init(name: String, colour: Color, context: NSManagedObjectContext) {
        self.init(name: name, context: context)
        let (r, g, b) = colour.rgbComponents
        let opacity = colour.opacityValue
        self.red = r
        self.green = g
        self.blue = b
        self.opacity = opacity
    }
    #endif
    
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
    
    var wrappedRed: Double {
        get { self.red }
        set { self.red = newValue }
    }
    
    var wrappedGreen: Double {
        get { self.green }
        set { self.green = newValue }
    }
    
    var wrappedBlue: Double {
        get { self.blue }
        set { self.blue = newValue }
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
