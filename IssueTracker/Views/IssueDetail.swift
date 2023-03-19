//
//  IssueDetail.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct IssueDetail: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var issue: Issue
    @StateObject private var viewModel: IssueDetailViewModel
    @State private var showingEditView = false
    @State private var showingCommentSheet = false
    
    init(issue: Issue) {
        self.issue = issue
        _viewModel = StateObject(wrappedValue: IssueDetailViewModel(issue: issue))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text(issue.wrappedName)
                        .headerStyle()
                    Divider()
                    
                    if !issue.wrappedIssueDescription.isEmpty {
                        Text(issue.wrappedIssueDescription)
                            .padding(.bottom)
                    } else {
                        Text("No Description")
                            .foregroundColor(.customSecondary)
                    }
                    Divider()
                    
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
                    
                    Divider()
                    
                    HStack(alignment: .lastTextBaseline) {
                        Text("Comments")
                            .headerStyle()
                        Spacer()
                        Button {
                            showingCommentSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ForEach(issue.sortedComments) { comment in
                        CommentBoxView(comment: comment, issue: issue)
                    }
                }
                .padding(.horizontal)
            }
            .bodyStyle()
            .background(Color.customBackground)
            .toolbarBackground(Color.customBackground)
            .sheet(isPresented: $showingCommentSheet) {
                AddCommentView(issue: issue)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .toolbar {
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
            .navigationDestination(for: Issue.self) { issue in
                EditIssueView(issue: issue)
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
