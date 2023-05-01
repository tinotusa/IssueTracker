//
//  CloudKitManager.swift
//  IssueTracker
//
//  Created by Tino on 14/4/2023.
//

import Foundation
import CloudKit
import os

struct CloudKitManager {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CloudKitManager.self)
    )
    var cloudKitError: CloudKitManagerError?
    var isSignedIn = false
    
    enum CloudKitManagerError: Error, LocalizedError {
        case couldNotDetermine
        case noAccount
        case restricted
        case temporarilyUnavailable
        case unknownError
        
        var errorDescription: String? {
            switch self {
            case .couldNotDetermine: return "Couldn't determine the account status for cloud kit."
            case .noAccount: return "Error no cloud kit account."
            case .restricted: return "The cloud kit account is restricted."
            case .temporarilyUnavailable: return "The cloud kit account is temporarily restricted."
            case .unknownError: return "Unknown error."
            }
        }
    }
}

extension CloudKitManager {
    func getAccountStatus() async throws -> CKAccountStatus {
        try await CKContainer.default().accountStatus()
    }
    
    func deleteComments(_ comments: [Comment]) async throws {
        logger.debug("Deleting \(comments.count) comments")
        await withThrowingTaskGroup(of: Void.self) { group in
            for comment in comments {
                group.addTask {
                    try await deleteComment(comment)
                }
            }
        }
    }
    
    func deleteIssues(_ issues: [Issue]) async {
        await withThrowingTaskGroup(of: Void.self) { group in
            for issue in issues {
                group.addTask {
                    try await deleteIssue(issue)
                }
            }
        }
    }
    
    func deleteIssue(_ issue: Issue) async throws {
        try await deleteComments(issue.wrappedComments)
    }
    
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
            
            for try await _ in group {
                
            }
        }
    }
    
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
