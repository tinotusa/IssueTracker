//
//  CloudKitManager.swift
//  IssueTracker
//
//  Created by Tino on 14/4/2023.
//

import Foundation
import CloudKit
import os

/// Manager for cloud kit operations.
struct CloudKitManager {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CloudKitManager.self)
    )
}

extension CloudKitManager {
    /// Returns the account status for the user.
    /// - Returns: The iCloud account status.
    func getAccountStatus() async throws -> CKAccountStatus {
        try await CKContainer.default().accountStatus()
    }
    
    /// Deletes the comment's attachments from iCloud.
    /// - Parameter comments: Comments to delete.
    func deleteComments(_ comments: [Comment]) async throws {
        logger.debug("Deleting \(comments.count) comments")
        try await withThrowingTaskGroup(of: Void.self) { group in
            for comment in comments {
                group.addTask {
                    try await deleteComment(comment)
                }
            }
            try await group.next()
        }
    }
    
    /// Delets the given issues from iCloud.
    /// - Parameter issues: The issues to delete.
    func deleteIssues(_ issues: [Issue]) async throws {
        try await withThrowingTaskGroup(of: Void.self) { group in
            for issue in issues {
                group.addTask {
                    try await deleteIssue(issue)
                }
            }
            try await group.next()
        }
    }
    
    /// Deletes the given issue from iCloud.
    /// - Parameter issue: The issue to delete.
    func deleteIssue(_ issue: Issue) async throws {
        try await deleteComments(issue.wrappedComments)
    }
    
    /// Deletes the given comment from iCloud.
    /// - Parameter comment: The comment to delete.
    func deleteComment(_ comment: Comment) async throws {
        logger.debug("Deleting comment with id: \(comment.wrappedId)")
        logger.debug("\(comment.wrappedAttachments.count) attachment")
        try await withThrowingTaskGroup(of: Void.self) { group in
            for attachment in comment.wrappedAttachments {
                guard let assetURL = attachment.assetURL else {
                    logger.debug("No asset url for attachment with id: \(attachment.wrappedId)")
                    continue
                }
                group.addTask {
                    try await deleteAttachment(withURL: assetURL)
                }
            }
            
            try await group.next()
        }
    }
    
    /// Deletes an attachment from iCloud.
    /// - Parameter assetURL: The asset url to delete.
    func deleteAttachment(withURL assetURL: URL) async throws {
        logger.debug("Deleting record with asset url: \(assetURL)")
        let database = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Attachment", predicate: .init(format: "attachmentURL == %@", assetURL.absoluteString))
        let records = try await database.records(matching: query)
        for (id, result) in records.matchResults {
            switch result {
            case .success(let record):
                // TODO: is this necessary?
                record["attachment"] = nil // set the asset to nil. which will be removed lazily later.
            case .failure(let error):
                logger.debug("Error trying to set record: \(id) asset url to nil. \(error)")
            }
        }
        
        let recordIDs = records.matchResults.compactMap( { recordID, _ in
            recordID
        })
        
        try await deleteRecords(recordIDs)
    }
    
    /// An async wrapper for deleting records from iCloud database.
    /// - Parameter recordIDs: The record IDs to delete.
    private func deleteRecords(_ recordIDs: [CKRecord.ID]) async throws {
        try await withCheckedThrowingContinuation { continuation in
            let database = CKContainer.default().privateCloudDatabase
            let deleteOperation = CKModifyRecordsOperation(recordIDsToDelete: recordIDs)
            deleteOperation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    logger.debug("Successfully completed the operation")
                    continuation.resume()
                case .failure(let error):
                    logger.debug("Failed to complete the delete operation. \(error)")
                    continuation.resume(throwing: error)
                }
            }
            
            deleteOperation.perRecordDeleteBlock = { id, result in
                switch result {
                case .success:
                    logger.debug("Successfully delete record with id: \(id)")
                case .failure(let error):
                    logger.debug("Failed to delete record with id: \(id). \(error)")
                }
            }
            database.add(deleteOperation)
        }
    }
}
