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
    @FetchRequest(sortDescriptors: [])
    private var issues: FetchedResults<Issue>
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: IssuesViewModel
    
    init(project: Project) {
        self.project = project
        _viewModel = StateObject(wrappedValue: IssuesViewModel(project: project))
        _issues = FetchRequest(
            sortDescriptors: [.init(\.dateCreated, order: .forward)],
            predicate: NSPredicate(format: "(project == %@) AND (status == %@)",  project, "open")
        )
    }
    
    var body: some View {
        List(issues) { issue in
            Button {
                viewModel.selectedIssue = issue
            } label: {
                IssueRowView(issue: issue)
            }
            .swipeActions {
                Button {
                    viewModel.setIssueStatus(issue, to: .closed)
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
                    viewModel.setIssueStatus(issue, to: .open)
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
        .onChange(of: viewModel.searchText) { _ in
            viewModel.runSearch()
            issues.nsPredicate = viewModel.predicate
        }
        .onChange(of: viewModel.searchScope) { _ in
            viewModel.runSearch()
            issues.nsPredicate = viewModel.predicate
        }
        .onChange(of: viewModel.searchIssueStatus) { _ in
            viewModel.runSearch()
            issues.nsPredicate = viewModel.predicate
        }
        .navigationBarTitle(viewModel.searchIssueStatus == .open ? "Open issues" : "Closed issues")
        .toolbarBackground(Color.customBackground, for: .navigationBar, .bottomBar) // this doesn't seem to change the bottom bar at all.
        .background(Color.customBackground)
        .sheet(isPresented: $viewModel.showingAddIssueView) {
            AddIssueView(project: project)
                .environment(\.managedObjectContext, viewContext)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.selectedIssue) { selectedIssue in
            IssueDetail(issue: selectedIssue)
        }
        .sheet(isPresented: $viewModel.showingEditTagsView) {
            TagsEditView()
                .environment(\.managedObjectContext, viewContext)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
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
                    viewModel.searchIssueStatus = viewModel.searchIssueStatus == .open ? .closed : .open
                } label: {
                    Label("Issue status", systemImage: viewModel.searchIssueStatus == .open ? "book.closed" : "book")
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
                    issues.sortDescriptors = [viewModel.sortDescriptor]
                } label: {
                    labelFor(.reverse, title: "Newest first")
                }
                Button {
                    viewModel.setSortOrder(to: .forward)
                    issues.sortDescriptors = [viewModel.sortDescriptor]
                } label: {
                    labelFor(.forward, title: "Oldest first")
                }
            case .priority, .title:
                Button {
                    viewModel.setSortOrder(to: .forward)
                    issues.sortDescriptors = [viewModel.sortDescriptor]
                } label: {
                    labelFor(.forward, title: "Ascending")
                }
                Button {
                    viewModel.setSortOrder(to: .reverse)
                    issues.sortDescriptors = [viewModel.sortDescriptor]
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
