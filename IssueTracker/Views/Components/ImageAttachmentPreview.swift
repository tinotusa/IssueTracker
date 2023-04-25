//
//  ImageAttachmentPreview.swift
//  IssueTracker
//
//  Created by Tino on 18/3/2023.
//

import SwiftUI

struct ImageAttachmentPreview: View {
    let image: Image
    let deleteAction: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            image
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
                .cornerRadius(10)
            Button(role: .destructive, action: deleteAction) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
    }
}

struct ImageAttachmentPreview_Previews: PreviewProvider {
    static var previews: some View {
        ImageAttachmentPreview(image: Image(systemName: "person")) {
            // do nothing
        }
    }
}
