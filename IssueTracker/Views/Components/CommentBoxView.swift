//
//  CommentBoxView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct CommentBoxView: View {
    @State private var showingAttachments = false
    
    @ObservedObject private(set) var comment: Comment
    @ObservedObject private(set) var issue: Issue
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(comment.wrappedComment)
            
            if comment.hasAttachments {
                HStack {
                    Text("^[\(comment.wrappedAttachments.count) Attachment](inflect: true)")
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
                        ForEach(comment.sortedAttachments) { attachment in
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
    static let viewContext = PersistenceController.issuesPreview.container.viewContext
    
    static var previews: some View {
        CommentBoxView(
            comment: .init(comment: "testing", context: viewContext),
            issue: .init(name: "test", issueDescription: "", priority: .low, tags: [], context: viewContext)
        )
    }
}
