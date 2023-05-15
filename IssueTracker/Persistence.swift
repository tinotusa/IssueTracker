//
//  Persistence.swift
//  IssueTracker
//
//  Created by Tino on 26/12/2022.
//

import CoreData
import os
import CloudKit

final class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing:  PersistenceController.self)
    )
    
    let container: NSPersistentContainer
    private let cloudKitManager = CloudKitManager()
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "IssueTracker")
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
        container.viewContext.undoManager = UndoManager()
    }
}

// MARK: - Issue functions
extension PersistenceController {
    /// Adds a new issue to core data.
    /// - Parameters:
    ///   - issueData: The data for the issue.
    ///   - project: The project the issue is a part of.
    func addIssue(_ issueData: IssueProperties,project: Project) async throws {
        let issue = Issue(
            name: issueData.name,
            issueDescription: issueData.issueDescription,
            priority: issueData.priority,
            tags: issueData.tags,
            context: viewContext
        )
        logger.debug("Adding new issue with id: \(issue.wrappedId)")
        project.addToIssues(issue)
        return try await save()
    }
    
    /// Copies values from the source issue to the destination issue.
    /// - Parameters:
    ///   - source: The issue to copy from.
    ///   - destination: The issue to copy to.
    ///   - tags: The tags from the source issue to copy to the destination.
    func updateIssue(_ issue: Issue, with issueProperties: IssueProperties) async throws {
        logger.debug("Updating issue: \(issue.wrappedId) with properties: \(issueProperties)")
        issue.copyProperties(from: issueProperties)
        
        return try await save()
    }
}

extension PersistenceController {
    /// The managed object context for the container.
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    /// Checks that the users is logged in to iCloud.
    func iCloudAccountCheck() async throws {
        let status = try await cloudKitManager.getAccountStatus()
        if status == .available {
            return
        }
        if viewContext.hasChanges {
            viewContext.rollback()
        }
        throw PersistenceError.noICloudAccount
    }
    
    /// Adds a new comment to core data.
    /// - Parameters:
    ///   - comment: The comment string to add.
    ///   - issue: The issue to add the comment to.
    ///   - attachmentTransferables: The image attachment(s) of the comment.
    ///   - audioURL: The audio attachment of the comment.
    @MainActor
    func addComment(_ commentProperties: CommentProperties, to issue: Issue) async throws {
        let comment = Comment(comment: commentProperties.comment, context: viewContext)
        
        let attachmentTransferables = try await commentProperties.getAttachmentsTransferables()
        logger.debug("Adding comment with id: \(comment.wrappedId)")
        objectWillChange.send()
        
        var attachments = [Attachment]()
        var records = [CKRecord]()
        
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
        
        // adding audio
        if let audioURL = commentProperties.audioURL {
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
        comment.addToAttachments(.init(array: attachments))
        issue.addToComments(comment)
        
        // save to coredata and cloudkit
        try await saveCloudKit(recordsToSave: records)
        
        return try await save()
    }
    
    private func saveCloudKit(recordsToSave records: [CKRecord]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let database = CKContainer.default().privateCloudDatabase
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: records)
            modifyOperation.qualityOfService = .userInitiated
            modifyOperation.modifyRecordsResultBlock = { [weak self] result in
                switch result {
                case .success:
                    self?.logger.debug("Successfully saved records")
                    continuation.resume()
                case .failure(let error):
                    self?.logger.error("Failed to save attachment records. \(error)")
                    continuation.resume(throwing: error)
                }
            }
            database.add(modifyOperation)
        }
    }

    /// Adds a new project to core data.
    /// - Parameter projectData: The data for the project.
    func addProject(_ projectData: ProjectProperties) async throws {
        let project = Project(name: projectData.name, startDate: projectData.startDate, context: viewContext)
        logger.debug("Adding new project with id: \(project.wrappedId)")
        return try await save()
    }
    
    /// Deletes the given objects from core data.
    /// - Parameter objects: The objects to delete.
    func deleteObjects<T: NSManagedObject>(_ objects: [T]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for object in objects {
                group.addTask { [weak self] in
                    try await self?.deleteObject(object)
                }
            }
            
            try await group.next()
        }
    }
    
    
    /// Updates a project with the project data.
    /// - Parameters:
    ///   - project: The project to update.
    ///   - projectData: The data used for the update.
    func updateProject(_ project: Project, projectData: ProjectProperties) async throws {
        project.wrappedName = projectData.name
        project.wrappedStartDate = projectData.startDate
        try await save()
    }
    
    /// Deletes the given object from core data.
    /// - Parameter object: The object to delete.
    func deleteObject<T: NSManagedObject>(_ object: T) async throws {
        logger.debug("Deleting object with id: \(object.objectID)")

        if let issue = object as? Issue {
            // TODO: Add task group?
            // TODO: make these if elses their own functions.
            for comment in issue.wrappedComments {
                for attachment in comment.wrappedAttachments {
                    guard let assetURL = attachment.assetURL else {
                        continue
                    }
                    
                    try await cloudKitManager.deleteAttachment(withURL: assetURL)
                }
            }
        } else if let project = object as? Project {
            logger.debug("Deleting object issues and comments.")
            let request = NSFetchRequest<Issue>(entityName: "Issue")
            request.predicate = NSPredicate(format: "project == %@", project)
            do {
                let issues = try PersistenceController.shared.viewContext.fetch(request)
                print("\(issues.count) to be deleted.")
                try await cloudKitManager.deleteIssues(issues)
            } catch {
                logger.error("Failed to get issue. \(error)")
            }
        } else if let comment = object as? Comment {
            logger.debug("comment \(comment.wrappedId) has \(comment.wrappedAttachments.count) attachments")
            
            try await cloudKitManager.deleteComment(comment)
        }
        
        viewContext.delete(object)
        return try await save()
    }
    
    /// Adds an attachment to a comment.
    /// - Parameters:
    ///   - attachmentType: The type of the attachment (Image or audio).
    ///   - attachmentURL: The URL for the attachment.
    ///   - comment: The comment to add the attachment to.
    func addAttachment(ofType attachmentType: AttachmentType, attachmentURL: URL, to comment: Comment) async throws {
        let attachment = Attachment(context: viewContext)
        attachment.assetURL = attachmentURL
        attachment.type = attachmentType.rawValue
        attachment.comment = comment
        attachment.id = UUID()
        attachment.dateCreated = .now
        
        comment.addToAttachments(attachment)
        logger.debug("Added new attachment to comment: \(comment.wrappedId).")
        return try await save()
    }
    
    @MainActor
    /// Commits the changes made to core data.
    func save() async throws {
        try await iCloudAccountCheck()
        if !viewContext.hasChanges {
            logger.debug("Failed to save. managed object has no changes.")
            return
        }
        try viewContext.save()
        logger.debug("Successfully saved managed object context.")
    }
    

    /// Adds a tag to core data
    /// - Parameter name: The name of the tag
    /// - Returns: `true` if the tag was added successfully, `false` otherwise.
    func addTag(named name: String) async throws {
        let tag = Tag(context: viewContext)
        tag.name = name
        tag.id = UUID()
        tag.dateCreated = .now
        return try await save()
    }
}

// MARK: - Preview
extension PersistenceController {
    /// A preview `PersistenceController` for previews.
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let project = Project(context: controller.viewContext)
        project.name = "New project"
        project.dateCreated = .now
        project.startDate = .now
        project.id = UUID()
        
        return controller
    }()
}
