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
    
    init(issue: Issue) {
        self.issue = issue
        _viewModel = StateObject(wrappedValue: IssueDetailViewModel(issue: issue))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            header
            ScrollView {
                VStack(alignment: .leading) {
                    Text(issue.name)
                        .headerStyle()
                    if !issue.issueDescription.isEmpty {
                        Text(issue.issueDescription)
                            .padding(.bottom)
                    } else {
                        Text("N/A")
                            .foregroundColor(.customSecondary)
                    }
                    Text("Created: \(issue.dateCreated.formatted(date: .abbreviated, time: .omitted))")
                    HStack {
                        Text("Priority:")
                        Text(issue.priority.title)
                    }
                    
                    LabeledInputField("Tags:") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            let tags = issue.tags?.array as? [Tag] ?? []
                            if tags.isEmpty {
                                Text("No tags")
                                    .foregroundColor(.customSecondary)
                            } else {
                                ForEach(tags) { tag in
                                    Text(tag.name)
                                }
                            }
                        }
                    }
                    HStack(alignment: .lastTextBaseline) {
                        Text("Comments")
                            .headerStyle()
                        Spacer()
                        Button {
                            viewModel.addNewEmptyComment()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ForEach($issue.wrappedComments) { $comment in
                        CommentBoxView(comment: comment, issue: issue)
                    }
                    
                }
            }
        }
        .padding()
        .bodyStyle()
        .background(Color.customBackground)
    }
}

private extension IssueDetail {
    var header: some View {
        HStack {
            PlainButton("Close") {
                dismiss()
            }
            Spacer()
            PlainButton("Edit") {
                // todo
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
    }
}
