//
//  AddCommentViewModel.swift
//  IssueTracker
//
//  Created by Tino on 18/3/2023.
//

import SwiftUI
import CloudKit
import CoreData
import PhotosUI
import os

final class AddCommentViewModel: ObservableObject {
    @Published var comment = ""
    @Published var recordingAudio = false // will probably change this
    @Published private(set) var showingPhotoPicker = false
    @Published var photoPickerItems = [PhotosPickerItem]()
    @Published private(set) var attachmentImages: [Image] = []
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AddCommentViewModel.self)
    )
}

extension AddCommentViewModel {
    var hasComment: Bool {
        let comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        return !comment.isEmpty
    }
}

extension AddCommentViewModel {
    @MainActor
    func loadImages(from photoItems: [PhotosPickerItem]) async {
        do {
            var attachmentImages: [Image] = []
            for photo in photoItems {
                
                guard let data = try await photo.loadTransferable(type: Data.self) else {
                    continue
                }
                guard let uiImage = UIImage(data: data) else {
                    continue
                }
                let image = Image(uiImage: uiImage)
                attachmentImages.append(image)
            }
            self.attachmentImages = attachmentImages
        } catch {
            // TODO: Display error message if one arises
            logger.error("error \(error)")
        }
    }
    
    @MainActor
    func addComment(issue: Issue, viewContext: NSManagedObjectContext, audioURL: URL? = nil) async {
        let comment = Comment(comment: comment, context: viewContext)
        let attachmentTransferables = await getAttachmentsTransferables()
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
            logger.debug("added audio url to core data attachment.")
            attachments.append(attachment)
        }
        issue.addToComments(comment)
        comment.addToAttachments(.init(array: attachments))
        
        // save to coredata and cloudkit
        do {
            try viewContext.save()
        
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
        } catch {
            logger.error("Failed to save context. \(error)")
        }
    }
    
    private func getAttachmentsTransferables() async -> [AttachmentTransferable] {
        var attachmentTransferables = [AttachmentTransferable]()
        do {
            for photo in photoPickerItems {
                let transferable = try await photo.loadTransferable(type: AttachmentTransferable.self)
                guard let transferable else {
                    logger.debug("failed to get image data")
                    continue
                }
                attachmentTransferables.append(transferable)
            }
        } catch {
            logger.error("Failed to get image transferables. \(error)")
        }
        return attachmentTransferables
    }
    
    @MainActor
    func deletePhotoItem(at index: Int) {
        photoPickerItems.remove(at: index)
    }
}
