//
//  Persistence.swift
//  IssueTracker
//
//  Created by Tino on 26/12/2022.
//

import CoreData
import os
import CloudKit

class PersistenceController {
    static let shared = PersistenceController()
    let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing:  PersistenceController.self)
    )
    
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

// MARK: - Issue functions
extension PersistenceController {
    func addIssue(
        name: String,
        issueDescription: String,
        priority: Issue.Priority,
        tags: Set<Tag>,
        project: Project
    ) throws {
        let issue = Issue(name: name, issueDescription: issueDescription, priority: priority, tags: tags, context: viewContext)
        project.addToIssues(issue)
        try save()
    }
    
    func toggleIssueStatus(for issue: Issue) throws {
        switch issue.wrappedStatus {
        case .open: issue.wrappedStatus = .closed
        case .closed: issue.wrappedStatus = .open
        }
        try save()
    }
    
    func setIssueStatus(for issue: Issue, to status: Issue.Status) throws {
        if issue.wrappedStatus == status {
            return
        }
        issue.wrappedStatus = status
        try save()
    }
    
    func copyIssue(from source: Issue, to destination: Issue, withTags tags: Set<Tag>) throws {
        destination.copyProperties(from: source)
        destination.tags = .init(set: tags)
        
        try save()
    }
}

#warning("add logging to these functions")
extension PersistenceController {
    var viewContext: NSManagedObjectContext {
        Self.shared.container.viewContext
    }
    
    func addComment(comment: String, to issue: Issue, attachments attachmentTransferables: [AttachmentTransferable]? = nil, audioAttachmentURL audioURL: URL? = nil) throws {
        logger.debug("Adding comment")
        let comment = Comment(comment: comment, context: viewContext)
        
        var attachments = [Attachment]()
        var records = [CKRecord]()
        if let attachmentTransferables {
            for attachmentTransferable in attachmentTransferables {
                // create coredata attachment entity
                let attachment = Attachment(context: viewContext)
                attachment.comment = comment
                attachment.dateCreated = .now
                attachment.id = UUID()
                attachment.type = attachmentTransferable.attachmentType.rawValue
                
                // create cloudkit attachment asset
                let imageAttachmentRecord = CKRecord(recordType: "Attachment")
                let asset = CKAsset(fileURL: attachmentTransferable.url)
                imageAttachmentRecord["type"] = attachmentTransferable.attachmentType.rawValue
                imageAttachmentRecord["attachment"] = asset
                imageAttachmentRecord["attachmentURL"] = asset.fileURL!.absoluteString
                
                records.append(imageAttachmentRecord)
                attachment.assetURL = asset.fileURL!
                attachments.append(attachment)
            }
        }
        // adding audio
        if let audioURL {
            // cloudkit audio attachment
            let audioAttachmentRecord = CKRecord(recordType: "Attachment")
            let asset = CKAsset(fileURL: audioURL)
            audioAttachmentRecord.setValuesForKeys([
                "type": AttachmentType.audio.rawValue,
                "attachment": asset,
                "attachmentURL": audioURL.absoluteString
            ])
            records.append(audioAttachmentRecord)
            // coredata audio attachment
            let attachment = Attachment(context: viewContext)
            attachment.comment = comment
            attachment.dateCreated = .now
            attachment.id = UUID()
            attachment.type = AttachmentType.audio.rawValue
            attachment.assetURL = asset.fileURL!
            
            attachments.append(attachment)
        }
        logger.debug("Added \(attachments.count) attachments to comment")
        issue.addToComments(comment)
        comment.addToAttachments(.init(array: attachments))
        
        // save to coredata and cloudkit
        do {
            try save()
            
            let database = CKContainer.default().privateCloudDatabase
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: records)
            modifyOperation.qualityOfService = .userInitiated
            modifyOperation.modifyRecordsResultBlock = { [weak self] result in
                switch result {
                case .success:
                    self?.logger.debug("Successfully saved records")
                case .failure(let error):
                    self?.logger.error("Failed to save attachment records. \(error)")
                }
            }
            database.add(modifyOperation)
        } catch {
            logger.error("Failed to add comment. \(error)")
        }
    }
    
    func addProject(name: String, dateStarted: Date) throws {
        let project = Project(name: name, startDate: dateStarted, context: viewContext)
        logger.debug("Adding new project with id: \(project.wrappedId)")
        try save()
        
    }
    
    func deleteObject<T: NSManagedObject>(_ object: T) throws {
        viewContext.delete(object)
        logger.debug("Deleting object with id: \(object.objectID)")
        try save()
    }
    
    func addAttachment(ofType attachmentType: AttachmentType, attachmentURL: URL, to comment: Comment) throws {
        let attachment = Attachment(context: viewContext)
        attachment.assetURL = attachmentURL
        attachment.type = attachmentType.rawValue
        attachment.comment = comment
        attachment.id = UUID()
        attachment.dateCreated = .now
        
        comment.addToAttachments(attachment)
        logger.debug("Added new attachment to comment: \(comment.wrappedId).")
        try save()
    }
    
    func save() throws {
        if !viewContext.hasChanges {
            logger.debug("Failed to save. managed object has no changes.")
            return
        }
        try viewContext.save()
        logger.debug("Successfully saved managed object context.")
    }
}

extension PersistenceController {
    static var preview: PersistenceController = {
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
