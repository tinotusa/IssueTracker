//
//  AttachmentType.swift
//  IssueTracker
//
//  Created by Tino on 9/3/2023.
//

import Foundation

/// The types of attachments that can be attached to comments.
enum AttachmentType: Int16 {
    // An image attachment.
    case image
    // A video attachment.
    case video
    // An audio attachment.
    case audio
}
