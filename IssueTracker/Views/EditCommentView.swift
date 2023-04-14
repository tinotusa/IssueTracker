//
//  EditCommentView.swift
//  IssueTracker
//
//  Created by Tino on 20/3/2023.
//

import SwiftUI

struct EditCommentView: View {
    @State private var showingCancelDialog = false
    @ObservedObject private(set) var comment: Comment
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    private let commentCopy: Comment
    
    init(comment: Comment) {
        _comment = ObservedObject(wrappedValue: comment)
        commentCopy = Comment.copy(source: comment)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Comment") {
                    TextField("Comment", text: $comment.wrappedComment, axis: .vertical)
                        .lineLimit(2 ... 5)
                        .textFieldStyle(.roundedBorder)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
                
                if !comment.wrappedAttachments.isEmpty {
                    Section("Attachments") {
                        ForEach(comment.sortedAttachments) { attachment in
                            let type = AttachmentType(rawValue: attachment.type)!
                            switch type {
                            case .image:
                                ImageAttachmentView(url: attachment.assetURL!)
                            case .audio:
                                AudioAttachmentView(url: attachment.assetURL!)
                            case .video:
                                Text("TODO")
                            }
                        }
                        .onDelete(perform: delete)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.customBackground)
                }
                
                Button("Save", action: save)
                    .buttonStyle(.borderedProminent)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.customBackground)
                    .disabled(!canSaveComment)
            }
            .listStyle(.plain)
            .navigationTitle("Edit comment")
            .background(Color.customBackground)
            .toolbar {
                toolbarContent
            }
            .confirmationDialog("Comment not saved.", isPresented: $showingCancelDialog) {
                Button(role: .destructive) {
                    dismiss()
                } label: {
                    Text("Don't save")
                }
            } message: {
                Text("Comment not saved.")
            }
        }
    }
}

// MARK: - Views
private extension EditCommentView {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                if commentHasChanges {
                    showingCancelDialog = true
                    return
                }
                dismiss()
            }
        }
        if comment.hasAttachments {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
    }
}

// MARK: - Functions
private extension EditCommentView {
    func delete(offsets indexSet: IndexSet) {
        for index in indexSet {
            let attachment = comment.sortedAttachments[index]
            comment.removeFromAttachments(attachment)
            // TODO: should i also remove the cloudkit asset?
        }
        _ = persistenceController.save()
    }
    
    var commentHasChanges: Bool {
        commentCopy.wrappedComment != comment.wrappedComment ||
        commentCopy.wrappedAttachments != comment.wrappedAttachments
    }
    
    var canSaveComment: Bool {
        let commentText = comment.wrappedComment.trimmingCharacters(in: .whitespacesAndNewlines)
        return (!commentText.isEmpty && commentHasChanges)
    }
    
    func save() {
        let didSave = persistenceController.save()
        if didSave {
            dismiss()
        }
    }
}

struct EditCommentView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    static var previews: some View {
        NavigationStack {
            EditCommentView(comment: .example)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(PersistenceController.preview)
        }
    }
}
