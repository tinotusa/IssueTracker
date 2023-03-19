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
        let paths = await getImagePaths()
        var attachments = [Attachment]()
        for path in paths {
            let attachment = Attachment(context: viewContext)
            attachment.comment = comment
            attachment.dateCreated = .now
            attachment.id = UUID()
            attachment.type = path.attachmentType.rawValue
            attachment.assetURL = path.url
            attachments.append(attachment)
        }
        // adding audio
        if let audioURL {
            logger.debug("trying to save audio.")
            let asset = CKAsset(fileURL: audioURL)
            let record = CKRecord(recordType: "Attachment")
            record.setValuesForKeys([
                "type": AttachmentType.audio.rawValue,
                "attachment": asset,
                "attachmentURL": audioURL.absoluteString
            ])
            let database = CKContainer.default().privateCloudDatabase
            do {
                try await database.save(record)
            } catch {
                logger.debug("Failed to save audio record to iCloud")
            }
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
        do {
            try viewContext.save()
        } catch {
            logger.error("Failed to save context. \(error)")
        }
    }
    
    private func getImagePaths() async -> [AttachmentTransferable] {
        var paths = [AttachmentTransferable]()
        do {
            for photo in photoPickerItems {
                let data = try await photo.loadTransferable(type: AttachmentTransferable.self)
                guard let data else {
                    logger.debug("failed to get image data")
                    continue
                }
                paths.append(data)
            }
        } catch {
            logger.error("Failed to get image paths. \(error)")
        }
        return paths
    }
    
    @MainActor
    func deletePhotoItem(at index: Int) {
        photoPickerItems.remove(at: index)
    }
}
