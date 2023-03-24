//
//  Persistence.swift
//  IssueTracker
//
//  Created by Tino on 26/12/2022.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container =  NSPersistentCloudKitContainer(name: "IssueTracker")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    static var preview: Self = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let project = Project(name: "Test project", startDate: .now, context: viewContext)
        
       
        
        var tags = Set<Tag>()
        for i in 0 ..< Int.random(in: 1 ..< 4) {
            let tag = Tag(name: "Tag\(i)", context: viewContext)
            tags.insert(tag)
        }
        
        var issues = [Issue]()
        for i in 0 ..< 4 {
            let issue = Issue(name: "Issue#\(i)", issueDescription: "testing", priority: .low, tags: tags, context: viewContext)
            issues.append(issue)
            
            var comments = Set<Comment>()
            for i in 0 ..< 3 {
                let comment = Comment(comment: "Comment #\(i)", context: viewContext)
                comments.insert(comment)
            }
            issue.addToComments(.init(set: comments))
            
        }
        project.addToIssues(.init(set: Set(issues)))

        try? viewContext.save()
        
        return controller
    }()
}
