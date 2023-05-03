//
//  AttachmentLoader.swift
//  IssueTracker
//
//  Created by Tino on 3/5/2023.
//

import os
import SwiftUI
import CloudKit

actor AttachmentLoader {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AttachmentLoader.self)
    )
    
    nonisolated func getAttachmentAssetURL(fromURL url: URL) async throws -> URL? {
        try await withCheckedThrowingContinuation { continuation in
            let query = CKQuery(
                recordType: "Attachment",
                predicate: .init(format: "attachmentURL == %@", url.absoluteString)
            )
            
            let operation = CKQueryOperation(query: query)
            operation.qualityOfService = .userInitiated
            var assetURL: URL?
            
            operation.recordMatchedBlock = { [weak self] id, result in
                guard let self else { return }
                switch result {
                case .failure(let error):
                    self.logger.debug("Failed to get audio record. \(error)")
                    return
                case .success(let record):
                    guard let asset = record["attachment"] as? CKAsset else {
                        self.logger.debug("failed to get audio asset")
                        return
                    }
                    assetURL = asset.fileURL
                }
            }
            
            operation.queryResultBlock = { [weak self] result in
                guard let self else { return }
                switch result {
                case.success:
                    continuation.resume(returning: assetURL)
                case .failure(let error):
                    self.logger.error("Failed to get attachment from cloudkit. \(error)")
                    continuation.resume(throwing: error)
                }
            }
            
            let database = CKContainer.default().privateCloudDatabase
            database.add(operation)
        }
    }
}
