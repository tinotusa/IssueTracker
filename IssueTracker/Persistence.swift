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
    @Published var errorWrapper: ErrorWrapper?
    private let cloudKitManager = CloudKitManager()
    
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
    /// Adds a new issue to core data.
    /// - Parameters:
    ///   - name: The name of the issue.
    ///   - issueDescription: The description of the issue.
    ///   - priority: The priority of the issue.
    ///   - tags: The tags associated with the issue.
    ///   - project: The project the issue is a part of.
    @MainActor
    func addIssue(
        name: String,
        issueDescription: String,
        priority: Issue.Priority,
        tags: Set<Tag>,
        project: Project
    ) async throws {
        let issue = Issue(name: name, issueDescription: issueDescription, priority: priority, tags: tags, context: viewContext)
        logger.debug("Adding new issue with id: \(issue.wrappedId)")
        project.addToIssues(issue)
        return try await save()
    }
    
    /// Toggles the issues status.
    /// - Parameter issue: The issue to toggle.
    @MainActor
    func toggleIssueStatus(for issue: Issue) async throws {
        switch issue.wrappedStatus {
        case .open: issue.wrappedStatus = .closed
        case .closed: issue.wrappedStatus = .open
        }
        return try await save()
    }
    
    /// Changes the issues status to the given status.
    /// - Parameters:
    ///   - issue: The issue to change.
    ///   - status: The status to set the issue to.
    @MainActor
    func setIssueStatus(for issue: Issue, to status: Issue.Status) async throws {
        if issue.wrappedStatus == status {
            return
        }
        objectWillChange.send()
        issue.wrappedStatus = status
        return try await save()
    }
    
    /// Copies values from the source issue to the destination issue.
    /// - Parameters:
    ///   - source: The issue to copy from.
    ///   - destination: The issue to copy to.
    ///   - tags: The tags from the source issue to copy to the destination.
    @MainActor
    func copyIssue(from source: Issue, to destination: Issue) async throws {
        logger.debug("Copying from issue: \(source.wrappedId) to issue: \(destination.wrappedId)")
        destination.copyProperties(from: source)
        
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
    func addComment(
        comment: String,
        to issue: Issue,
        attachments attachmentTransferables: [AttachmentTransferable]? = nil,
        audioAttachmentURL audioURL: URL? = nil
    ) async throws {
        let comment = Comment(comment: comment, context: viewContext)
        logger.debug("Adding comment with id: \(comment.wrappedId)")
        
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
        comment.addToAttachments(.init(array: attachments))
        issue.addToComments(comment)
        // save to coredata and cloudkit
        
        
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
        return try await save()
    }
    
    /// Adds a new project to core data.
    /// - Parameters:
    ///   - name: The name of the project.
    ///   - dateStarted: The start date for the project.
    @MainActor
    func addProject(name: String, dateStarted: Date) async throws {
        let project = Project(name: name, startDate: dateStarted, context: viewContext)
        logger.debug("Adding new project with id: \(project.wrappedId)")
        return try await save()
    }
    
//    func requestCloudKitAccount() async throws {
//        let status = try await cloudKitManager.getAccountStatus()
//        if status != .available {
//            logger.debug("iCloud account is not available. current status is: \(status.rawValue)")
//            return
//        }
//    }
    
    /// Deletes the given object from core data.
    /// - Parameter object: The object to delete.
    @MainActor
    func deleteObject<T: NSManagedObject>(_ object: T) async throws {
        logger.debug("Deleting object with id: \(object.objectID)")
//        let isSignedIn = await requestCloudKitAccount()
//        if !isSignedIn {
//            showingError = true
//            persistenceError = .noICloudAccount
//            return false
//        }
        if let issue = object as? Issue {
            for comment in issue.wrappedComments {
                for attachment in comment.wrappedAttachments {
                    guard let assetURL = attachment.assetURL else {
                        continue
                    }
                    
                    await cloudKitManager.deleteAttachment(withURL: assetURL)
                }
            }
        } else if let project = object as? Project {
            logger.debug("Deleting object issues and comments.")
            let request = NSFetchRequest<Issue>(entityName: "Issue")
            request.predicate = NSPredicate(format: "project == %@", project)
            do {
                let issues = try PersistenceController.shared.viewContext.fetch(request)
                print("\(issues.count) to be deleted.")
                await cloudKitManager.deleteIssues(issues)
            } catch {
                logger.error("Failed to get issue. \(error)")
            }
        } else if let comment = object as? Comment {
            logger.debug("comment \(comment.wrappedId) has \(comment.wrappedAttachments.count) attachments")
            
            await cloudKitManager.deleteComment(comment)
        }
        
        viewContext.delete(object)
        return try await save()
    }
    
    /// Adds an attachment to a comment.
    /// - Parameters:
    ///   - attachmentType: The type of the attachment (Image or audio).
    ///   - attachmentURL: The URL for the attachment.
    ///   - comment: The comment to add the attachment to.
    @MainActor
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
    
    @MainActor
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
    /// A preview `PersistenceController` for the ui previews.
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
