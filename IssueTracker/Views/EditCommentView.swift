//
//  EditCommentView.swift
//  IssueTracker
//
//  Created by Tino on 20/3/2023.
//

import SwiftUI
import CloudKit

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
            guard let assetURL = attachment.assetURL else {
                continue
            }
            Task {
                let database = CKContainer.default().privateCloudDatabase
                let query = CKQuery(recordType: "Attachment", predicate: .init(format: "attachmentURL == %@", assetURL.absoluteString))
                do {
                    let records = try await database.records(matching: query)
                    for (id, result) in records.matchResults {
                        switch result {
                        case .success(let record):
                            record["attachment"] = nil // set the asset to nil. which will be removed lazily later.
                        case .failure(let error):
                            print("Error trying to set record: \(id) asset url to nil. \(error)")
                        }
                    }
                    
                    let recordIDs = records.matchResults.compactMap { recordID, _ in
                        recordID
                    }
                    
                    let deleteOperation = CKModifyRecordsOperation(recordIDsToDelete: recordIDs)
                    deleteOperation.modifyRecordsResultBlock = { result in
                        switch result {
                        case .success:
                            print("Successfully completed the operation")
                        case .failure(let error):
                            print("Failed to complete the delete operation. \(error)")
                        }
                    }
                    deleteOperation.perRecordDeleteBlock = { id, result in
                        switch result {
                        case .success:
                            print("Successfully delete record with id: \(id)")
                        case .failure(let error):
                            print("Failed to delete record with id: \(id). \(error)")
                        }
                    }
                    database.add(deleteOperation)
                } catch {
                    print("something went wrong.")
                }
            }
        }
        _ = persistenceController.save()
    }
    
    var commentHasChanges: Bool {
        commentCopy.wrappedComment != comment.wrappedComment ||
        commentCopy.wrappedAttachments.count != comment.wrappedAttachments.count
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
