//
//  Comment+preview.swift
//  IssueTracker
//
//  Created by Tino on 23/3/2023.
//

import Foundation

extension Comment {
    @discardableResult
    /// Creates preview comments.
    /// - Parameter count: The amount of comments to create.
    /// - Returns: An array of comments.
    static func makePreviews(count: Int) -> [Comment] {
        var comments = [Comment]()
        for _ in 0 ..< count {
            let comment = Comment(context: PersistenceController.preview.container.viewContext)
            comment.comment = String.generateLorem()
            comment.id = UUID()
            comment.dateCreated = .now
            comments.append(comment)
        }
        return comments
    }
    
    /// A preview comment.
    static var preview: Comment = {
        let comments = Comment.makePreviews(count: 1)
        return comments[0]
    }()
}
