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
        let redHex = String(r, radix: 16).leftPadding(toLength: 2, withPad: "0")
        let greenHex = String(g, radix: 16).leftPadding(toLength: 2, withPad: "0")
        let blueHex = String(b, radix: 16).leftPadding(toLength: 2, withPad: "0")
        let opacity = colour.opacityValue
        self.colour = "\(redHex)\(greenHex)\(blueHex)"
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
    
    var wrappedColour: String {
        get { self.colour ?? "ffffff" }
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
