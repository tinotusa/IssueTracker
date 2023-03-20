//
//  EditCommentView.swift
//  IssueTracker
//
//  Created by Tino on 20/3/2023.
//

import SwiftUI

struct EditCommentView: View {
    @ObservedObject private(set) var comment: Comment
    @Environment(\.managedObjectContext) private var viewContext
    
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
                        .onDelete { indexSet in
                            for index in indexSet {
                                let attachment = comment.sortedAttachments[index]
                                comment.removeFromAttachments(attachment)
                                // TODO: should i also remove the cloudkit asset?
                            }
                            do {
                                try viewContext.save()
                            } catch {
                                print("Failed to remove attachment. \(error)")
                            }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.customBackground)
                }
                
                Button("Save") {
                    do {
                        try viewContext.save()
                    } catch {
                        print("Failed to save comment change. \(error)")
                    }
                }
                .buttonStyle(.borderedProminent)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
            }
            .listStyle(.plain)
            .navigationTitle("Edit comment")
            .background(Color.customBackground)
        }
        .toolbar {
            if comment.hasAttachments {
                ToolbarItem(placement: .primaryAction) {
                    EditButton()
                }
            }
        }
    }
}

struct EditCommentView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.issuesPreview.container.viewContext
    static var previews: some View {
        NavigationStack {
            EditCommentView(comment: Comment(comment: "testing", context: viewContext))
        }
    }
}
