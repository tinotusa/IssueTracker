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
        self.dateCreated_ = .now
        self.id_ = UUID()
    }
}

// MARK: Properties
extension Tag {
    var dateCreated: Date {
        get { self.dateCreated_ ?? .now }
        set { self.dateCreated_ = newValue }
    }
    
    var red: Double {
        get { self.red_ }
        set { self.red_ = newValue }
    }
    
    var green: Double {
        get { self.green_ }
        set { self.green_ = newValue }
    }
    
    var blue: Double {
        get { self.blue_ }
        set { self.blue_ = newValue }
    }
    
    public var id: UUID {
        get { self.id_ ?? UUID() }
        set { self.id_ = newValue }
    }
    
    var name: String {
        get { self.name_ ?? "N/A" }
        set { self.name_ = newValue }
    }
    
    var opacity: Double {
        get { self.opacity_ }
        set { self.opacity_ = newValue }
    }
}
