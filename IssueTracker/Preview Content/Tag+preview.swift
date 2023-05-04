//
//  Tag+preview.swift
//  IssueTracker
//
//  Created by Tino on 23/3/2023.
//

import Foundation

extension Tag {
    /// Creates tags for previews.
    /// - Parameter count: The amount of tags to create.
    /// - Returns: An array of tags.
    static func makePreviews(count: Int) -> [Tag] {
        let viewContext = PersistenceController.preview.container.viewContext
        var tags = [Tag]()
        for _ in 0 ..< count {
            let tag = Tag(context: viewContext)
            tag.dateCreated = .now
            tag.id = UUID()
            tag.name = String.generateLorem(ofLength: 1)
            tag.blue = 0
            tag.red = 0
            tag.green = 0
            tag.opacity = 1
            
            tags.append(tag)
        }
        return tags
    }
    
    /// A preview tag.
    static var preview: Tag {
        let tags = Self.makePreviews(count: 1)
        return tags[0]
    }
}
