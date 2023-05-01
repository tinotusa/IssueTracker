//
//  IssueProperties.swift
//  IssueTracker
//
//  Created by Tino on 12/4/2023.
//

import Foundation

/// A struct that encapsulates the properties of an `Issue`.
struct IssueProperties: Equatable, CustomStringConvertible {
    /// The name of the issue.
    var name = ""
    /// The description of the issue.
    var issueDescription = ""
    /// The priority of the issue.
    var priority: Issue.Priority = .low
    /// The tags of the issue.
    var tags: Set<Tag> = []
    /// The tags sorted in alphabetical order.
    var sortedTags: [Tag] = []
    /// The date the issue was created.
    var dateCreated: Date = .now
    
    var description: String {
        "name: \(name), issueDescription: \(issueDescription), priority: \(priority),  tags: \(tags)"
    }
}

extension IssueProperties {
    /// A boolean value indicating whether or not all the input fields are filled.
    var allFieldsFilled: Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !name.isEmpty
    }
    
    /// The default IssueProperties.
    static var `default`: Self {
        .init()
    }
}
