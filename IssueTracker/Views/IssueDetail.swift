//
//  IssueDetail.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct IssueDetail: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private(set) var issue: Issue
    @StateObject private var viewModel: IssueDetailViewModel
    @State private var showingEditView = false
    @State private var showingCommentSheet = false
    @State private var showingEditCommentView = false
    @State private var commentToEdit: Comment? = nil
    
    init(issue: Issue) {
        self.issue = issue
        // TODO: This will be illegal in a future update
        _viewModel = StateObject(wrappedValue: IssueDetailViewModel(issue: issue))
    }
    
    var body: some View {
        NavigationStack {
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
            .sheet(isPresented: $showingCommentSheet) {
                AddCommentView(issue: issue)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingEditCommentView) {
                if let commentToEdit {
                    EditCommentView(comment: commentToEdit)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
            .toolbar {
                toolbarItems
            }
            .navigationDestination(for: Issue.self) { issue in
                EditIssueView(issue: issue)
            }
            .navigationDestination(for: URL.self) { imageURL in
                ImageDetailView(url: imageURL)
            }
        }
    }
}

private extension IssueDetail {
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
                    .swipeActions {
                        Button(role: .destructive) {
                            viewModel.deleteComment(comment)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            showingEditCommentView = true
                            commentToEdit = comment
                        } label: {
                            Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                        }
                        .tint(.blue)
                    }
            }
            
            Button("Add comment") {
                showingCommentSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .listRowSeparator(.hidden)
    }
    
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") {
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            NavigationLink(value: issue) {
                Text("Edit")
                    .foregroundColor(.buttonLabel)
            }
        }
    }
}

struct IssueDetail_Previews: PreviewProvider {
    static let viewContext = PersistenceController.issuesPreview.container.viewContext
    static var previews: some View {
        IssueDetail(issue: .init(
            name: "test issue",
            issueDescription: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras imperdiet sodales arcu, vitae congue risus iaculis ut. Quisque vitae varius leo. In interdum neque eros, non porta diam laoreet in. Pellentesque sed tortor tempus, efficitur sem quis, volutpat diam. Aenean ut posuere odio. In vehicula eu nulla sed mollis. ",
            priority: .low,
            tags: [],
            context: viewContext)
        )
        .environment(\.managedObjectContext, viewContext)
    }
}
