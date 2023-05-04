//
//  CommentBoxView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct CommentBoxView: View {
    let comment: Comment
    @State private var showingAttachments = false
    
    var attachments: [Attachment] {
        comment.wrappedAttachments
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(comment.wrappedComment)
            
            if !attachments.isEmpty {
                HStack {
                    Text("^[\(attachments.count) Attachment](inflect: true)")
                        .foregroundColor(.secondary)
                    Button(showingAttachments ? "Hide" : "Show") {
                        withAnimation {
                            showingAttachments.toggle()
                        }
                    }
                    .foregroundColor(.blue)
                }
                .font(.footnote)
            }
            if showingAttachments {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(attachments) { attachment in
                            let attachmentType = AttachmentType(rawValue: attachment.type)!
                            let url = attachment.assetURL!
                            switch attachmentType {
                            case .audio:
                                AudioAttachmentView(url: url)
                            case .image:
                                ImageAttachmentView(url: url)
                            case .video:
                                Text("TODO")
                            }
                        }
                    }
                }
            }
            Text(comment.wrappedDateCreated.formatted(date: .abbreviated, time: .omitted))
                .footerStyle()
        }
        .padding()
        .background(Color.popup)
        .cornerRadius(10)
    }
}

struct CommentBoxView_Previews: PreviewProvider {
    static var previews: some View {
        CommentBoxView(comment: .preview)
    }
}
