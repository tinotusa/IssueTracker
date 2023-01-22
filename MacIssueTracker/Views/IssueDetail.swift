//
//  IssueDetail.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct IssueDetail: View {
    @ObservedObject var issue: Issue
    @StateObject private var viewModel: IssueDetailViewModel
    @FetchRequest(sortDescriptors: [])
    private var comments: FetchedResults<Comment>
    @FetchRequest(sortDescriptors: [])
    private var tags: FetchedResults<Tag>
    @State private var showingEditIssueView = false
    @Environment(\.managedObjectContext) private var viewContext
    
    init(issue: Issue) {
        _issue = ObservedObject(wrappedValue: issue)
        _viewModel = StateObject(wrappedValue: IssueDetailViewModel(issue: issue))
        _comments = FetchRequest<Comment>(
            sortDescriptors: [.init(\.dateCreated_, order: .forward)],
            predicate: .init(format: "issue == %@", issue)
        )
        _tags = FetchRequest<Tag>(
            sortDescriptors: [.init(\.name_, order: .forward)],
            predicate: .init(format: "%@ in issues", issue)
        )
    }
    
    var body: some View {
        Form {
            Text(issue.dateCreated.formatted(date: .long, time: .shortened))
                .font(.footnote)
                .foregroundColor(.secondary)
            Text(issue.name)
                .titleStyle()
            Divider()
            descriptionSection
            prioritySection
            tagsSection
            commentsSection
        }
        .bodyStyle()
        .safeAreaInset(edge: .bottom) {
            HStack {
                TextEditor(text: $viewModel.comment)
                    .frame(maxHeight: 100)
                Button("Add comment") {
                    viewModel.addComment()
                }
                .disabled(viewModel.comment.isEmpty)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditIssueView = true
                }
            }
        }
        .sheet(isPresented: $showingEditIssueView) {
            EditIssueView(issue: issue)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

// MARK: - Subviews
private extension IssueDetail {
    var descriptionSection: some View {
        Section {
            Group {
                if issue.issueDescription.isEmpty {
                    Text("No Description")
                        .foregroundColor(.secondary)
                } else {
                    Text(issue.issueDescription)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
        } header: {
            Text("Description")
                .titleStyle()
        }
    }
    
    var prioritySection: some View {
        Section {
            Text(issue.priority.title)
                .padding(.bottom)
        } header: {
            Text("Priority")
                .titleStyle()
        }
    }
    
    var tagsSection: some View {
        Section {
            Group {
                if tags.isEmpty {
                    Text("No tags")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(tags)) { tag in
                        Text(tag.name)
                    }
                }
            }
            .padding(.bottom)
        } header: {
            Text("Tags")
                .titleStyle()
        }
    }
    
    var commentsSection: some View {
        Section {
            Divider()
            if comments.isEmpty {
                Text("No comments")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(Array(comments)) { comment in
                            CommentView(comment: comment)
                        }
                    }
                }
            }
        } header: {
            Text("Comments")
                .titleStyle()
        }
    }
}

// MARK: - Previews
struct IssueDetail_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    static var issue = Issue(name: "some issue", issueDescription: "", priority: .low, tags: [], context: viewContext)
    static var previews: some View {
        IssueDetail(issue: issue)
    }
}
