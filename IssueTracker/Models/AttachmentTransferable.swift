//
//  AttachmentTransferable.swift
//  IssueTracker
//
//  Created by Tino on 9/3/2023.
//

import Foundation
import CloudKit
import SwiftUI

// TODO: Rename to something like Attachment (can't use Attachment because that is a coredata entity)
struct AttachmentTransferable: Transferable {
    let url: URL
    let attachmentType: AttachmentType
    
    #warning("look up how to save to icloud in background queue")
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .jpeg) { jpeg in
            return SentTransferredFile(jpeg.url)
        } importing: { received in
            let attachmentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "attachmentsFolder/")
            if !FileManager.default.fileExists(atPath: attachmentsFolder.path()) {
                do {
                    print("Folder doesn't exist trying to create a new one")
                    try FileManager.default.createDirectory(atPath: attachmentsFolder.path(), withIntermediateDirectories: true)
                    print("Successfully created new folder.")
                } catch {
                    print("Failed to create directory. \(error)")
                }
            }
            
            let copy = attachmentsFolder.appending(path: UUID().uuidString)
            
            print("the received file is: \(received.file)")
            print("the copy path is:  \(copy)")
            try FileManager.default.copyItem(at: received.file, to: copy)
            let record = CKRecord(recordType: "Attachment")
            let asset = CKAsset(fileURL: copy)
            record.setValuesForKeys([
                "type": AttachmentType.image.rawValue,
                "attachment": asset,
                "attachmentURL": asset.fileURL!.absoluteString
            ])
            let database = CKContainer.default().privateCloudDatabase
            database.save(record) { record, error in
                // TODO: Add logic to test is user is logged in.
                if let error {
                    print("Failed to save record to database. \(error)")
                }
                print("Successfully saved new record to cloudkit")
            }
            return Self.init(url: asset.fileURL!, attachmentType: .image)
        }
        
        // TODO: These file reps are the exact same. Is there a way to change this?
        FileRepresentation(contentType: .png) { png in
            return SentTransferredFile(png.url)
        } importing: { received in
            let attachmentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "attachmentsFolder/")
            if !FileManager.default.fileExists(atPath: attachmentsFolder.path()) {
                do {
                    print("Folder doesn't exist trying to create a new one")
                    try FileManager.default.createDirectory(atPath: attachmentsFolder.path(), withIntermediateDirectories: true)
                    print("Successfully created new folder.")
                } catch {
                    print("Failed to create directory. \(error)")
                }
            }
            let copy = attachmentsFolder.appending(path: UUID().uuidString)
            let record = CKRecord(recordType: "Attachment")
            let asset = CKAsset(fileURL: received.file)
            record.setValuesForKeys([
                "type": AttachmentType.image.rawValue,
                "attachment": asset,
                "attachmentURL": asset.fileURL!.absoluteString
            ])
            let database = CKContainer.default().privateCloudDatabase
            database.save(record) { record, error in
                if let error {
                    print("Failed to save record to database. \(error)")
                }
                print("Successfully saved new record to cloudkit")
            }
            print("the received file is: \(received.file)")
            print("the copy path is:  \(copy)")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: asset.fileURL!, attachmentType: .image)
        }
    }
}
