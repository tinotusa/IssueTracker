//
//  IssueSummary.swift
//  IssueTracker
//
//  Created by Tino on 16/4/2023.
//

import SwiftUI

struct IssueSummary: View {
    let issue: Issue
    @State private var errorWrapper: ErrorWrapper?
    @EnvironmentObject private var persistenceController: PersistenceController
    
    var body: some View {
        List {
            Group {
                titleSection
                descriptionSection
                tagsSection
                infoSection
                commentsSection
            }
            .listRowBackground(Color.customBackground)
        }
        .safeAreaInset(edge: .bottom) {
            AddCommentBox(issue: issue)
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
            Text(issue.wrappedName)
        }
        .listRowSeparator(.hidden)
    }
    
    var descriptionSection: some View {
        Section("Description") {
            if !issue.wrappedIssueDescription.isEmpty {
                Text(issue.wrappedIssueDescription)
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
                let tags = issue.sortedTags
                if tags.isEmpty {
                    Text("No tags")
                        .foregroundColor(.customSecondary)
                } else {
                    HStack {
                        ForEach(tags) { tag in
                            ProminentTagView(tag: tag, isSelected: true)
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
                Text("Created: \(issue.wrappedDateCreated.formatted(date: .abbreviated, time: .omitted))")
                HStack {
                    Text("Priority:")
                    Text(issue.wrappedPriority.title)
                }
            }
        }
        .listRowSeparator(.hidden)
    }
    
    var commentsSection: some View {
        Section("Comments") {
            ForEach(issue.wrappedComments) { comment in
                CommentBoxView(comment: comment)
                    .swipeActions {
                        Button(role: .destructive) {
                            deleteComment(comment)
                        } label: {
                            Label("Delete", systemImage: SFSymbol.trash)
                        }
                    }
            }
        }
        .listRowSeparator(.hidden)
    }
}

// MARK: - Functions
private extension IssueSummary {
    func deleteComment(_ comment: Comment) {
        Task {
            do {
                try await persistenceController.deleteObject(comment)
            } catch {
                errorWrapper = .init(error: error, message: "Failed to delete comment.")
            }
        }
    }
}

struct IssueSummary_Previews: PreviewProvider {
    static var previews: some View {
        IssueSummary(issue: .preview)
            .environmentObject(PersistenceController.preview)
    }
}
