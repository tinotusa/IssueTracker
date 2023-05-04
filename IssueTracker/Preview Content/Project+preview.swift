//
//  Project+preview.swift
//  IssueTracker
//
//  Created by Tino on 23/3/2023.
//

import Foundation

extension Project {
    static func makePreviews(count: Int) -> [Project] {
        let viewContext = PersistenceController.preview.container.viewContext
        var projects = [Project]()
        
        for _ in 0 ..< count {
            let project = Project(context: viewContext)
            project.dateCreated = .now
            project.id = UUID()
            project.name = String.generateLorem(ofLength: 3)
            project.startDate = .now
            
            let issues = Issue.makePreviews(count: 5)
            for issue in issues {
                let tags = Tag.makePreviews(count: Int.random(in: 1 ..< 4))
                let comments = Comment.makePreviews(count: Int.random(in: 1 ..< 5))
                issue.addToComments(.init(array: comments))
                issue.addToTags(.init(array: tags))
            }
            project.addToIssues(.init(array: issues))
            
            projects.append(project)
        }
        
        return projects
    }
    
    static var preview: Project {
        let projects = Self.makePreviews(count: 1)
        return projects[0]
    }
}
