//
//  AttachmentTransferable.swift
//  IssueTracker
//
//  Created by Tino on 9/3/2023.
//

import Foundation
import CloudKit
import SwiftUI
import os

struct AttachmentTransferable: Transferable {
    let url: URL
    let attachmentType: AttachmentType
    private static let log = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AttachmentTransferable.self)
    )
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .jpeg) { jpeg in
            return SentTransferredFile(jpeg.url)
        } importing: { received in
            let attachmentsFolder = URL.documentsDirectory.appending(path: "attachmentsFolder/")
            if !FileManager.default.fileExists(atPath: attachmentsFolder.path()) {
                do {
                    log.debug("Folder doesn't exist trying to create a new one")
                    try FileManager.default.createDirectory(atPath: attachmentsFolder.path(), withIntermediateDirectories: true)
                    log.debug("Successfully created new folder.")
                } catch {
                    log.debug("Failed to create directory. \(error)")
                }
            }
            
            let copy = attachmentsFolder.appending(path: "\(UUID().uuidString).jpeg")
            
            log.debug("the received file is: \(received.file)")
            log.debug("the copy path is:  \(copy)")
            try FileManager.default.copyItem(at: received.file, to: copy)
            let record = CKRecord(recordType: "Attachment")
            let asset = CKAsset(fileURL: copy)
            record.setValuesForKeys([
                "type": AttachmentType.image.rawValue,
                "attachment": asset,
                "attachmentURL": asset.fileURL!.absoluteString
            ])
            let database = CKContainer.default().privateCloudDatabase
            let config = CKOperation.Configuration()
            config.qualityOfService = .userInitiated
            Task {
                await database.configuredWith(configuration: config) { database in
                    do {
                        try await database.save(record)
                    } catch {
                        log.error("Failed to save to data base. \(error)")
                    }
                }
            }
            
            return Self.init(url: asset.fileURL!, attachmentType: .image)
        }
        
        // TODO: These file reps are the exact same. Is there a way to change this?
        FileRepresentation(contentType: .png) { png in
            return SentTransferredFile(png.url)
        } importing: { received in
            let attachmentsFolder = URL.documentsDirectory.appending(path: "attachmentsFolder/")
            if !FileManager.default.fileExists(atPath: attachmentsFolder.path()) {
                do {
                    log.debug("Folder doesn't exist trying to create a new one")
                    try FileManager.default.createDirectory(atPath: attachmentsFolder.path(), withIntermediateDirectories: true)
                    log.debug("Successfully created new folder.")
                } catch {
                    log.debug("Failed to create directory. \(error)")
                }
            }
            let copy = attachmentsFolder.appending(path: "\(UUID().uuidString).png")
            try FileManager.default.copyItem(at: received.file, to: copy)
            let record = CKRecord(recordType: "Attachment")
            let asset = CKAsset(fileURL: received.file)
            record.setValuesForKeys([
                "type": AttachmentType.image.rawValue,
                "attachment": asset,
                "attachmentURL": asset.fileURL!.absoluteString
            ])
            
            let database = CKContainer.default().privateCloudDatabase
            let config = CKOperation.Configuration()
            config.qualityOfService = .userInitiated
            Task {
                await database.configuredWith(configuration: config) { database in
                    do {
                        try await database.save(record)
                    } catch {
                        log.error("Failed to save record to database. \(error)")
                    }
                }
            }
            
            log.debug("the received file is: \(received.file)")
            log.debug("the copy path is:  \(copy)")
            
            return Self.init(url: asset.fileURL!, attachmentType: .image)
        }
    }
}
