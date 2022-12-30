//
//  CommentBoxView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct CommentBoxView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var comment: Comment
    let issue: Issue
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    @State private var originalComment = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                TextEditor(text: $comment.comment)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 30)
            } else {
                Text(comment.comment)
            }
            HStack {
                Text(comment.dateCreated.formatted(date: .abbreviated, time: .omitted))
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
                        originalComment = comment.comment
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
