//
//  IssuesView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI
import CoreData

struct IssuesView: View {
    private let project: Project
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: IssuesViewModel
    
    init(project: Project) {
        self.project = project
        let predicate = NSPredicate(format: "(project == %@) AND (status_ == %@)",  project, "open")
        _viewModel = StateObject(wrappedValue: IssuesViewModel(project: project, predicate: predicate))
    }
    
    var body: some View {
        FilteredIssuesListView(
            sortDescriptor: viewModel.sortDescriptor,
            predicate: viewModel.predicate
        ) { issue in
            Button {
                viewModel.selectedIssue = issue
            } label: {
                IssueRowView(issue: issue)
            }
            .swipeActions {
                Button {
                    viewModel.closeIssue(issue)
                } label: {
                    Label("Close issue", systemImage: "checkmark.circle.fill")
                }
                .tint(.green)
                Button(role: .destructive) {
                    viewModel.deleteIssue(issue)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    viewModel.openIssue(issue)
                } label: {
                    Label("Open", systemImage: "lock.open")
                }
                .tint(.purple)
            }
        }
        .searchable(text: $viewModel.searchText)
        .searchScopes($viewModel.searchScope) {
            ForEach(IssuesViewModel.SearchScopes.allCases) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .onChange(of: viewModel.searchText) { _ in viewModel.runSearch() }
        .onChange(of: viewModel.searchScope) { _ in viewModel.runSearch() }
        .onChange(of: viewModel.showingOpenIssues) { _ in viewModel.runSearch() }
        .navigationBarTitle(viewModel.showingOpenIssues ? "Open issues" : "Closed issues")
        .toolbarBackground(Color.customBackground, for: .navigationBar, .bottomBar) // this doesn't seem to change the bottom bar at all.
        .bodyStyle()
        .background(Color.customBackground)
        .sheet(isPresented: $viewModel.showingAddIssueView) {
            AddIssueView(project: project)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(item: $viewModel.selectedIssue) { selectedIssue in
            IssueDetail(issue: selectedIssue)
        }
        .sheet(isPresented: $viewModel.showingEditTagsView) {
            TagsEditView()
                .environment(\.managedObjectContext, viewContext)
        }
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    sortBySection
                    sortTypeSection
                } label: {
                    Text("Sort")
                }
                Button("Edit tags") {
                    viewModel.showingEditTagsView = true
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    viewModel.showingOpenIssues.toggle()
                } label: {
                    Label("Issue status", systemImage: viewModel.showingOpenIssues ? "book.closed" : "book")
                }
                
                Button {
                    viewModel.showingAddIssueView = true
                } label: {
                    Label("Add Issue", systemImage: "square.and.pencil")
                }
            }
        }
    }
}

private extension IssuesView {
    @ViewBuilder
    func labelFor(_ sortOrder: SortOrder, title: LocalizedStringKey) -> some View {
        if viewModel.sortOrder == sortOrder {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }
    
    var sortBySection: some View {
        Section("Sort by") {
            ForEach(IssuesViewModel.SortType.allCases) { sortType in
                Button {
                    viewModel.sortType = sortType
                } label: {
                    if viewModel.sortType == sortType {
                        Label(sortType.title, systemImage: "checkmark")
                    } else {
                        Text(sortType.title)
                    }
                }
            }
        }
    }
    
    var sortTypeSection: some View {
        Section {
            switch viewModel.sortType {
            case .date:
                Button {
                    viewModel.setSortOrder(to: .reverse)
                } label: {
                    labelFor(.reverse, title: "Newest first")
                }
                Button {
                    viewModel.setSortOrder(to: .forward)
                } label: {
                    labelFor(.forward, title: "Oldest first")
                }
            case .priority, .title:
                Button {
                    viewModel.setSortOrder(to: .forward)
                } label: {
                    labelFor(.forward, title: "Ascending")
                }
                Button {
                    viewModel.setSortOrder(to: .reverse)
                } label: {
                    labelFor(.reverse, title: "Descending")
                }
            }
        }
    }
}

struct IssuesView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.issuesPreview.container.viewContext
    
    static var previews: some View {
        NavigationStack {
            IssuesView(project: .example(context: viewContext))
                .environment(
                    \.managedObjectContext,
                     viewContext
            )
        }
    }
}
