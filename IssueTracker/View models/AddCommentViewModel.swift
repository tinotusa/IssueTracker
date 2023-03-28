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
    private lazy var persistenceController = PersistenceController.shared
    
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
    
    func addComment(issue: Issue, viewContext: NSManagedObjectContext, audioURL: URL? = nil) async {
        let attachmentTransferables = await getAttachmentsTransferables()
        do {
            try persistenceController.addComment(comment: comment, to: issue, attachments: attachmentTransferables, audioAttachmentURL: audioURL)
        } catch {
            logger.error("Failed to add comment. \(error)")
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
