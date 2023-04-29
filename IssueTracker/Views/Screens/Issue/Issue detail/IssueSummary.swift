//
//  IssueSummary.swift
//  IssueTracker
//
//  Created by Tino on 16/4/2023.
//

import SwiftUI

struct IssueSummary: View {
    let issueProperties: IssueProperties
    let comments: [Comment]
    let deleteCommentAction: (Comment) -> Void
    let addCommentAction: (CommentProperties) -> Void
    @State private var errorWrapper: ErrorWrapper?
    
    var body: some View {
        List {
            Group {
                titleSection
                descriptionSection
                infoSection
                commentsSection
            }
            .listRowBackground(Color.customBackground)
        }
        .safeAreaInset(edge: .bottom) {
            AddCommentBox(postAction: addCommentAction)
                .padding(.horizontal)
        }
        .listStyle(.plain)
        .background(Color.customBackground)
        .toolbarBackground(Color.customBackground)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $errorWrapper) { error in
            ErrorView(errorWrapper: error)
        }
    }
}

// MARK: - Views
private extension IssueSummary {
    var titleSection: some View {
        Section("Title") {
            Text(issueProperties.name)
        }
        .listRowSeparator(.hidden)
    }
    
    var descriptionSection: some View {
        Section("Description") {
            if !issueProperties.issueDescription.isEmpty {
                Text(issueProperties.issueDescription)
                    .padding(.bottom)
            } else {
                Text("No Description")
                    .foregroundColor(.customSecondary)
            }
        }
        .listRowSeparator(.hidden)
    }
    
    var tagsSection: some View {
        Section("Tags") {
            ScrollView(.horizontal, showsIndicators: false) {
                let tags = issueProperties.tags
                if tags.isEmpty {
                    Text("No tags")
                        .foregroundColor(.customSecondary)
                } else {
                    HStack {
                        ForEach(Array(tags)) { tag in
                            TagView(tag: tag)
                        }
                    }
                }
            }
        }
        .listRowSeparator(.hidden)
    }
    
    var infoSection: some View {
        Section("Info") {
            VStack(alignment: .leading) {
                Text("Created: \(issueProperties.dateCreated.formatted(date: .abbreviated, time: .omitted))")
                HStack {
                    Text("Priority:")
                    Text(issueProperties.priority.title)
                }
            }
        }
        .listRowSeparator(.hidden)
    }
    
    var commentsSection: some View {
        Section("Comments") {
            ForEach(comments) { comment in
                CommentBoxView(comment: comment.wrappedComment, attachments: comment.sortedAttachments)
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteCommentAction(comment)
                        } label: {
                            Label("Delete", systemImage: SFSymbol.trash)
                        }
                    }
            }
        }
        .listRowSeparator(.hidden)
    }
}

struct IssueSummary_Previews: PreviewProvider {
    static var previews: some View {
        IssueSummary(
            issueProperties: .default,
            comments: [],
            deleteCommentAction: { _ in },
            addCommentAction: { _ in }
        )
    }
}
