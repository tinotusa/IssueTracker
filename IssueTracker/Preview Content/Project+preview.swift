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
        
        let tags = Tag.makePreviews(count: Int.random(in: 4 ..< 12))
        
        for _ in 0 ..< count {
            let project = Project(context: viewContext)
            project.dateCreated = .now
            project.id = UUID()
            project.name = String.generateLorem(ofLength: 3)
            project.startDate = .now
            
            let issues = Issue.makePreviews(count: 5, createTags: false)
            
            for issue in issues {
                let comments = Comment.makePreviews(count: Int.random(in: 1 ..< 5))
                let tags = tags.shuffled().prefix(Int.random(in: 1 ..< 5))
                issue.addToComments(.init(array: comments))
                issue.addToTags(.init(set: Set(tags)))
            }
            
            project.addToIssues(.init(array: issues))
            
            projects.append(project)
        }
        
        return projects
    }
    
    static var preview: Project = {
        let projects = Project.makePreviews(count: 1)
        return projects[0]
    }()
}
