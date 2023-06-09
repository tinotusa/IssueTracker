//
//  Issue+preview.swift
//  IssueTracker
//
//  Created by Tino on 23/3/2023.
//

import Foundation

extension Issue {
    /// Creates preview Issues.
    /// - Parameter count: The number of issues to create.
    /// - Returns: An array of issues.
    static func makePreviews(count: Int, createTags: Bool = true) -> [Issue] {
        let viewContext = PersistenceController.preview.container.viewContext
        var issues = [Issue]()
        
        for _ in 0 ..< count {
            let issue = Issue(context: viewContext)
            issue.dateCreated = .now
            issue.id = UUID()
            issue.issueDescription = String.generateLorem(ofLength: 20)
            issue.name = String.generateLorem(ofLength: 4)
            issue.priority = Issue.Priority.allCases.randomElement()!.rawValue
            
            if createTags {
                let tags = Tag.makePreviews(count: Int.random(in: 1 ..< 5))
                issue.addToTags(.init(set: Set(tags)))
            }
            
            let comments = Comment.makePreviews(count: Int.random(in: 1 ..< 3))
            
            issue.addToComments(.init(array: comments))
            
            issues.append(issue)
        }
        return issues
    }
    
    /// A preview issue.
    static var preview: Issue = {
        let issues = Issue.makePreviews(count: 1)
        return issues[0]
    }()
}
