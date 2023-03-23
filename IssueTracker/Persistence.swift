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
    static var tagsPreview: Self {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        for i in 0 ..< 4 {
            _ = Tag(name: "Tag\(i)", context: viewContext)
        }
        return controller
    }
    
    static var issuesPreview: Self = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        for i in 0 ..< 10 {
            _ = Issue(name: "Issue#\(i)", issueDescription: "testing", priority: .low, tags: [], context: viewContext)
        }
        try? viewContext.save()
        return controller
    }()
    
    static var commentsPreview: Self = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        for i in 0 ..< 3 {
            let comment = Comment(comment: "Comment #\(i)", context: viewContext)
        }
        return controller
    }()
    
    static var projectsPreview: Self = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        for i in 0 ..< 4 {
            let project = Project(name: "name\(i)", startDate: .now, context: viewContext)
            
            for i in 0 ..< Int.random(in: 0 ..< 5) {
                let issue = Issue(name: "Issue#\(i)", issueDescription: "testing", priority: .init(rawValue: Int16.random(in: 0 ..< 3))!, tags: [], context: viewContext)
                issue.project = project
            }
            
        }
        return controller
    }()
    
    static var empty: Self {
        let controller = PersistenceController(inMemory: true)
        return controller
    }
}
