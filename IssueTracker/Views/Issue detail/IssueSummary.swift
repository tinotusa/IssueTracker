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
                case .showingAddCommentSheet:
                    AddCommentView(issue: issue)
                case .showingEditCommentView(let comment):
                    EditCommentView(comment: comment)
                case .showingEditIssueView:
                    EditIssueView(issue: issue)
                }
            }
            .sheetWithIndicator()
        }
    }
}

// MARK: - Views
private extension IssueSummary {
    enum IssueDetailState: Hashable, Identifiable {
        case showingAddCommentSheet
        case showingEditCommentView(comment: Comment)
        case showingEditIssueView
        
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
    
    
    var infoSection: some View {
        Section("Info") {
            VStack(alignment: .leading) {
                Text("Created: \(issue.wrappedDateCreated.formatted(date: .abbreviated, time: .omitted))")
                HStack {
                    Text("Priority:")
                    Text(issue.wrappedPriority.title)
                }
                
                LabeledInputField("Tags:") {
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
                            Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
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
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
            
            Button("Add comment") {
                issueDetailState = .showingAddCommentSheet
            }
            .buttonStyle(.borderedProminent)
        }
        .listRowSeparator(.hidden)
    }
}

struct IssueSummary_Previews: PreviewProvider {
    static var previews: some View {
        IssueSummary(issue: .example)
    }
}
