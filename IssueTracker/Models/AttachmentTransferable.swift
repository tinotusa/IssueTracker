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
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AttachmentTransferable.self)
    )
    
    static func createAttachment(from received: ReceivedTransferredFile, named filename: String) throws -> Self {
        let attachmentsFolder = URL.documentsDirectory.appending(path: "attachmentsFolder/")
        if !FileManager.default.fileExists(atPath: attachmentsFolder.path()) {
            do {
                try FileManager.default.createDirectory(atPath: attachmentsFolder.path(), withIntermediateDirectories: true)
            } catch {
                logger.error("Failed to create directory. \(error)")
            }
        }
        let copy = attachmentsFolder.appending(path: filename)
        try FileManager.default.copyItem(at: received.file, to: copy)
        
        return Self.init(url: copy, attachmentType: .image)
    }
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .jpeg) { jpeg in
            return SentTransferredFile(jpeg.url)
        } importing: { received in
            return try createAttachment(from: received, named: "\(UUID().uuidString).jpeg")
        }
        
        FileRepresentation(contentType: .png) { png in
            return SentTransferredFile(png.url)
        } importing: { received in
            return try createAttachment(from: received, named: "\(UUID().uuidString).png")
        }
    }
}
