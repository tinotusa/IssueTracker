//
//  CommentProperties.swift
//  IssueTracker
//
//  Created by Tino on 22/4/2023.
//

import SwiftUI
import PhotosUI
import os

private actor ImageAttachmentLoader {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ImageAttachmentLoader.self)
    )
    
    func loadImages(_ photoPickerItems: [PhotosPickerItem]) async throws -> [Image] {
        try await withThrowingTaskGroup(of: Image?.self) { group in
            for photo in photoPickerItems {
                group.addTask {
                    let data = try await photo.loadTransferable(type: Data.self)
                    guard let data else { return nil }
                    let uiImage = UIImage(data: data)
                    guard let uiImage else { return nil }
                    let image = Image(uiImage: uiImage)
                    return image
                }
            }
            var attachmentImages: [Image] = []
            for try await image in group {
                guard let image else { continue }
                attachmentImages.append(image)
            }
            logger.debug("Finished loading the images.")
            return attachmentImages
        }
    }
}

/// A struct that encapsulates the properties of a `Comment`.
@MainActor
class CommentProperties: ObservableObject {
    /// The comment text of the `Comment`.
    @Published var comment = ""
    /// The selected photos from the photo picker.
    @Published var photoPickerItems = [PhotosPickerItem]()
    /// The image attachments of the Comment.
    @Published var images: [Image] = []
    /// The audio attachment of the Comment.
    @Published var audioURL: URL? = nil
    private let imageLoader = ImageAttachmentLoader()
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CommentProperties.self)
    )
}

// MARK: - Computed Properties
extension CommentProperties {
    /// A boolean value indicating whether or not the comment is valid.
    /// A comment is valid if it is not empty.
    var hasValidComment: Bool {
        let comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        return !comment.isEmpty
    }
    
    /// Resets to the default state.
    func reset() {
        comment = ""
        photoPickerItems = []
        images = []
        audioURL = nil
    }
}

// MARK: - Functions
extension CommentProperties {
    func loadImages() async throws {
        logger.debug("Loading images with \(self.photoPickerItems.count) photos picker items")
        let images = try await imageLoader.loadImages(photoPickerItems)
        self.images = images
    }
    
    func getAttachmentsTransferables() async throws -> [AttachmentTransferable] {
        var attachmentTransferables = [AttachmentTransferable]()
        
        for photo in photoPickerItems {
            let transferable = try await photo.loadTransferable(type: AttachmentTransferable.self)
            guard let transferable else {
                logger.debug("failed to get image data")
                continue
            }
            attachmentTransferables.append(transferable)
        }
        
        return attachmentTransferables
    }
}

@MainActor
extension Binding where Value == CommentProperties {
    func loadImages() async throws {
        try await wrappedValue.loadImages()
    }
}
