//
//  Tag+Extensions.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import Foundation

extension Tag {
    
}

// MARK: Properties
extension Tag {
    var dateCreated: Date {
        get { self.dateCreated_ ?? .now }
        set { self.dateCreated_ = newValue }
    }
    
    var hexColour: String {
        get { self.hexColour_ ?? "ffffff" }
        set { self.hexColour_ = newValue }
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
