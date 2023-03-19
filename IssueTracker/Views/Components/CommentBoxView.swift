//
//  CommentBoxView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct CommentBoxView: View {
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    @State private var originalComment = ""
    @State private var showingAttachments = false
    
    @ObservedObject private(set) var comment: Comment
    @ObservedObject private(set) var issue: Issue
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                TextEditor(text: $comment.wrappedComment)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 30)
            } else {
                Text(comment.wrappedComment)
                if !comment.wrappedAttachments.isEmpty {
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
                            ForEach(comment.wrappedAttachments) { attachment in
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
            }
            HStack {
                Text(comment.wrappedDateCreated.formatted(date: .abbreviated, time: .omitted))
                    .footerStyle()
                Spacer()
                if isEditing {
                    Button("Save") {
                        issue.addToComments(comment)
                        withAnimation {
                            isEditing = false
                        }
                        try? viewContext.save()
                    }
                    Button("Cancel") {
                        comment.comment = originalComment
                        withAnimation {
                            isEditing = false
                        }
                    }
                } else {
                    Button {
                        originalComment = comment.wrappedComment
                        withAnimation {
                            isEditing = true
                        }
                    } label: {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    }
                }
                if !isEditing {
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .padding()
        .background(Color.popup)
        .cornerRadius(10)
        .confirmationDialog("Delete comment", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {   
                issue.removeFromComments(comment)
                // TODO: Delete the attachment files as well.
                withAnimation {
                    try? viewContext.save()
                }
            }
        } message: {
            Text("Delete this comment.")
        }
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
