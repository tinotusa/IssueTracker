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
    
    func deleteComments(_ comments: [Comment]) async {
        logger.debug("Deleting \(comments.count) comments")
        await withTaskGroup(of: Void.self) { group in
            for comment in comments {
                group.addTask {
                    await deleteComment(comment)
                }
            }
        }
    }
    
    func deleteIssues(_ issues: [Issue]) async {
        await withTaskGroup(of: Void.self) { group in
            for issue in issues {
                group.addTask {
                    await deleteIssue(issue)
                }
            }
        }
    }
    
    func deleteIssue(_ issue: Issue) async {
        await deleteComments(issue.wrappedComments)
    }
    
    func deleteComment(_ comment: Comment) async {
        logger.debug("Deleting comment with id: \(comment.wrappedId)")
        logger.debug("\(comment.wrappedAttachments.count) attachment")
        await withTaskGroup(of: Void.self) { group in
            for attachment in comment.wrappedAttachments {
                guard let assetURL = attachment.assetURL else {
                    logger.debug("No asset url for attachment with id: \(attachment.wrappedId)")
                    continue
                }
                group.addTask {
                    await deleteAttachment(withURL: assetURL)
                }
            }
        }
    }
    
    func deleteAttachment(withURL assetURL: URL) async {
        logger.debug("Deleting record with asset url: \(assetURL)")
        let database = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Attachment", predicate: .init(format: "attachmentURL == %@", assetURL.absoluteString))
        do {
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
            
            let deleteOperation = CKModifyRecordsOperation(recordIDsToDelete: recordIDs)
            deleteOperation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    logger.debug("Successfully completed the operation")
                case .failure(let error):
                    logger.debug("Failed to complete the delete operation. \(error)")
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
        } catch {
            logger.debug("something went wrong. \(error)")
        }
    }
}
