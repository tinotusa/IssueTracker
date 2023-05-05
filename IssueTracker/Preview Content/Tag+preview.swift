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
        func randomHex() -> String {
            let r = Int.random(in: 0 ..< 255)
            let g = Int.random(in: 0 ..< 255)
            let b = Int.random(in: 0 ..< 255)
            let rHex = String(r, radix: 16).leftPadding(toLength: 2, withPad: "0")
            let gHex = String(g, radix: 16).leftPadding(toLength: 2, withPad: "0")
            let bHex = String(b, radix: 16).leftPadding(toLength: 2, withPad: "0")
            return "\(rHex)\(gHex)\(bHex)"
        }
        
        let viewContext = PersistenceController.preview.container.viewContext
        var tags = [Tag]()
        for _ in 0 ..< count {
            let tag = Tag(context: viewContext)
            tag.dateCreated = .now
            tag.id = UUID()
            tag.name = String.generateLorem(ofLength: 1)
            tag.colour = randomHex()
            tag.opacity = Double.random(in: 0 ..< 1)
            
            tags.append(tag)
        }
        return tags
    }
    
    /// A preview tag.
    static var preview: Tag = {
        let tags = Tag.makePreviews(count: 1)
        return tags[0]
    }()
}
