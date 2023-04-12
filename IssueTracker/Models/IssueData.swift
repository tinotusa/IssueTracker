//
//  IssueData.swift
//  IssueTracker
//
//  Created by Tino on 12/4/2023.
//

import Foundation

struct IssueData {
    var name = ""
    var description = ""
    var priority: Issue.Priority = .low
    var tags: Set<Tag> = []
}

extension IssueData {
    var allFieldsFilled: Bool {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !name.isEmpty
    }
}
