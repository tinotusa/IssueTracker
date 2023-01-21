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
    
    init(issue: Issue) {
        _issue = ObservedObject(wrappedValue: issue)
        _viewModel = StateObject(wrappedValue: IssueDetailViewModel(issue: issue))
    }
    
    var body: some View {
        Form {
            Text(issue.name)
                .titleStyle()
            Text("Created: \(issue.dateCreated.formatted(date: .abbreviated, time: .shortened))")
                .foregroundColor(.secondary)
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
                    // TODO: implement
                }
            }
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
                } else {
                    Text(issue.issueDescription)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.gray)
            }
        } header: {
            Text("Description")
                .titleStyle()
        }
    }
    
    var prioritySection: some View {
        Section {
            Text(issue.priority.title)
        } header: {
            Text("Priority")
                .titleStyle()
        }
    }
    
    var tagsSection: some View {
        Section {
            #warning("Add tags as set property")
            if let tags = issue.tags?.set as? Set<Tag>, tags.isEmpty {
                Text("No tags")
                    .foregroundColor(.secondary)
            } else {
                if let tags = issue.tags?.set as? Set<Tag> {
                    ForEach(Array(tags)) { tag in
                        Text(tag.name)
                    }
                }
            }
        } header: {
            Text("Tags")
                .titleStyle()
        }
    }
    
    var commentsSection: some View {
        Section {
            if let comments = issue.comments?.set as? Set<Comment>, comments.isEmpty {
                Text("No comments")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    VStack(alignment: .leading) {
                        if let comments = issue.comments?.set as? Set<Comment> {
                            #warning("Add comments view")
                            ForEach(Array(comments)) { comment in
                                VStack {
                                    Text(comment.comment)
                                    HStack {
                                        Spacer()
                                        Button {
                                            // edit button
                                        } label: {
                                            Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                                        }
                                        Button(role: .destructive) {
                                            // delete code
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.gray)
                                }
                            }
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
