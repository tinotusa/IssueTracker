//
//  CommentProperties.swift
//  IssueTracker
//
//  Created by Tino on 22/4/2023.
//

import SwiftUI
import PhotosUI
import os

/// A struct that encapsulates the properties of a `Comment`.
struct CommentProperties {
    /// The comment text of the `Comment`.
    var comment = ""
    var photoPickerItems = [PhotosPickerItem]()
    /// The image attachments of the Comment.
    var images: [Image] = []
    /// The audio attachment of the Comment.
    var audioURL: URL? = nil
    /// A boolean value indicating whether or no audio is being recorded
    var isRecordingAudio = false

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: CommentProperties.self)
    )
    
    var hasValidComment: Bool {
        let comment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
        return !comment.isEmpty
    }
    
    var canAddComment: Bool  {
        hasValidComment && !isRecordingAudio
    }
    
    static var `default`: Self {
        .init()
    }
}

// MARK: - Functions
extension CommentProperties {
    mutating func loadImages() async throws {
        var attachmentImages: [Image] = []
        
        for photo in photoPickerItems {
            guard let data = try await photo.loadTransferable(type: Data.self) else {
                continue
            }
            guard let uiImage = UIImage(data: data) else {
                continue
            }
            let image = Image(uiImage: uiImage)
            attachmentImages.append(image)
        }
        
        self.images = attachmentImages
    }
    
    func getAttachmentsTransferables() async throws -> [AttachmentTransferable] {
        var attachmentTransferables = [AttachmentTransferable]()
        
        for photo in photoPickerItems {
            let transferable = try await photo.loadTransferable(type: AttachmentTransferable.self)
            guard let transferable else {
                Self.logger.debug("failed to get image data")
                continue
            }
            attachmentTransferables.append(transferable)
        }
        
        return attachmentTransferables
    }
    
    mutating func deleteImage(at index: Int) {
        guard index >= 0 && index < photoPickerItems.count else {
            return
        }
        photoPickerItems.remove(at: index)
    }
    
    mutating func toggleRecording() {
        isRecordingAudio.toggle()
    }
}

@MainActor
extension Binding where Value == CommentProperties {
    func loadImages() async throws {
        try await wrappedValue.loadImages()
    }
}
