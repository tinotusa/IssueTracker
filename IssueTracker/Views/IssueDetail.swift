//
//  IssueDetail.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct IssueDetail: View {
    @State private var issueDetailState: IssueDetailState? = nil
    @StateObject private var viewModel: IssueDetailViewModel
    @ObservedObject private(set) var issue: Issue
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistenceController: PersistenceController
    
    init(issue: Issue) {
        _issue = ObservedObject(wrappedValue: issue)
        _viewModel = StateObject(wrappedValue: IssueDetailViewModel(issue: issue))
    }
    
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
        .persistenceErrorAlert(isPresented: $persistenceController.showingError, presenting: $persistenceController.persistenceError)
        .toolbar {
            toolbarItems
        }
        .navigationDestination(for: URL.self) { imageURL in
            ImageDetailView(url: imageURL)
        }
    }
}

private extension IssueDetail {
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
                                _ = await persistenceController.deleteObject(comment)
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
    
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Edit") {
                issueDetailState = .showingEditIssueView
            }
        }
    }
}

struct IssueDetail_Previews: PreviewProvider {
    static let viewContext = PersistenceController.preview.container.viewContext
    static var previews: some View {
        IssueDetail(issue: .example)
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PersistenceController.preview)
    }
}
