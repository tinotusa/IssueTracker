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
    static let shared = CloudKitManager()
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CloudKitManager.self)
    )
}

extension CloudKitManager {
    func deleteAttachment(withURL assetURL: URL) async {
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
                    Self.logger.debug("Error trying to set record: \(id) asset url to nil. \(error)")
                }
            }
            
            let recordIDs = records.matchResults.compactMap( { recordID, _ in
                recordID
            })
            
            let deleteOperation = CKModifyRecordsOperation(recordIDsToDelete: recordIDs)
            deleteOperation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    Self.logger.debug("Successfully completed the operation")
                case .failure(let error):
                    Self.logger.debug("Failed to complete the delete operation. \(error)")
                }
            }
            deleteOperation.perRecordDeleteBlock = { id, result in
                switch result {
                case .success:
                    Self.logger.debug("Successfully delete record with id: \(id)")
                case .failure(let error):
                    Self.logger.debug("Failed to delete record with id: \(id). \(error)")
                }
            }
            database.add(deleteOperation)
        } catch {
            Self.logger.debug("something went wrong. \(error)")
        }
    }
}
