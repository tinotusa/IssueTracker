//
//  ImageAttachmentsRow.swift
//  IssueTracker
//
//  Created by Tino on 29/4/2023.
//

import SwiftUI

struct ImageAttachmentsRow: View {
    let images: [Image]
    let deleteAction: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0 ..< images.count, id: \.self) { index in
                    ImageAttachmentPreview(image: images[index]) {
                        deleteAction(index)
                    }
                }
            }
        }
    }
}

struct ImageAttachmentsRow_Previews: PreviewProvider {
    static var previews: some View {
        ImageAttachmentsRow(images: []) { _ in
            // no action for preview
        }
    }
}
