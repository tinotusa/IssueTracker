//
//  IssueSummary.swift
//  IssueTracker
//
//  Created by Tino on 16/4/2023.
//

import SwiftUI

struct IssueSummary: View {
    let issue: Issue
    @State private var issueDetailState: IssueDetailState?
    @State private var errorWrapper: ErrorWrapper?
    
    @EnvironmentObject private var persistenceController: PersistenceController
    
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
            AddCommentBox(postAction: addComment)
                .padding(.horizontal)
        }
        .listStyle(.plain)
        .background(Color.customBackground)
        .toolbarBackground(Color.customBackground)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $errorWrapper) { error in
            ErrorView(errorWrapper: error)
        }
        .sheet(item: $issueDetailState) { state in
            Group {
                switch state {
                case .showingEditCommentView(let comment):
                    EditCommentView(comment: comment)
                }
            }
            .sheetWithIndicator()
        }
    }
}

// MARK: - Views
private extension IssueSummary {
    enum IssueDetailState: Hashable, Identifiable {
        case showingEditCommentView(comment: Comment)
        
        var id: Self { self }
    }
    
    var titleSection: some View {
        Section("Title") {
            Text(issue.wrappedName)
                .headerStyle()
                .listRowSeparator(.hidden)
        }
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
                let tags = issue.tags?.allObjects as? [Tag] ?? []
                if tags.isEmpty {
                    Text("No tags")
                        .foregroundColor(.customSecondary)
                } else {
                    HStack {
                        ForEach(tags) { tag in
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
            ForEach(issue.sortedComments) { comment in
                CommentBoxView(comment: comment, issue: issue)
                    .swipeActions(edge: .leading) {
                        Button {
                            issueDetailState = .showingEditCommentView(comment: comment)
                        } label: {
                            Label("Edit", systemImage: SFSymbol.rectangleAndPencilAndEllipsis)
                        }
                        .tint(.blue)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                do {
                                    try await persistenceController.deleteObject(comment)
                                } catch {
                                    errorWrapper = .init(error: error, message: "Failed to delete comment.")
                                }
                            }
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
    func addComment(_ commentProperties: CommentProperties) {
        Task {
            do {
                try await persistenceController.addComment(commentProperties, to: issue)
            } catch {
                errorWrapper = .init(error: error, message: "Failed to add comment.")
            }
        }
    }
}

struct IssueSummary_Previews: PreviewProvider {
    static var previews: some View {
        IssueSummary(issue: .example)
    }
}
