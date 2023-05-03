//
//  AttachmentLoadingState.swift
//  IssueTracker
//
//  Created by Tino on 3/5/2023.
//

import Foundation

/// The loading state of an attachment.
enum AttachmentLoadingState {
    /// The attachment is loading.
    case loading
    /// The attachment has loaded.
    case loaded(url: URL)
    /// The attachment's assetURL is nil.
    case urlNotFound
    /// An error occured during loading.
    case error(error: Error)
}
