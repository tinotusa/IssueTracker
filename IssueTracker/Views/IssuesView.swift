//
//  IssuesView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI
import CoreData

struct IssuesView: View {
    @ObservedObject private(set) var project: Project
    
    @State private var showingDeleteIssueConfirmation = false
    
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
                trailingSwipeActions(issue: issue)
            }
            .listRowBackground(Color.customBackground)
        }
        .listStyle(.plain)
        .searchable(text: $viewModel.searchText)
        .searchScopes($viewModel.searchScope) {
            ForEach(IssuesViewModel.SearchScopes.allCases) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .onChange(of: viewModel.searchText) { _ in
            handleChange()
        }
        .onChange(of: viewModel.searchScope) { _ in
            handleChange()
        }
        .onChange(of: viewModel.searchIssueStatus) { _ in
            handleChange()
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
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showingEditTagsView) {
            TagsEditView()
                .environment(\.managedObjectContext, viewContext)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .toolbar {
            toolbarItems
        }
        .confirmationDialog("Delete issue", isPresented: $showingDeleteIssueConfirmation) {
            Button(role: .destructive) {
                guard let issue = viewModel.selectedIssue else {
                    return
                }
                viewModel.deleteIssue(issue)
            } label: {
                Text("Delete")
            }
        } message: {
            Text("Are you sure you want to delete this issue?")
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
    
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
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
                Label(
                    "Issue status",
                    systemImage: viewModel.searchIssueStatus == .open ? "tray.and.arrow.down.fill" : "tray.and.arrow.up.fill"
                )
            }

            Button {
                viewModel.showingAddIssueView = true
            } label: {
                Label("Add Issue", systemImage: "square.and.pencil")
            }
        }
    }
    
    @ViewBuilder
    func trailingSwipeActions(issue: Issue) -> some View {
        Button {
            switch issue.wrappedStatus {
            case .closed:
                viewModel.setIssueStatus(issue, to: .open)
            case .open:
                viewModel.setIssueStatus(issue, to: .closed)
            }
        } label: {
            Label(
                issue.isOpenStatus ? "Close issue" : "Open Issue",
                systemImage: issue.isOpenStatus ? "tray.and.arrow.down.fill" : "tray.and.arrow.up.fill"
            )
        }
        .tint(issue.isOpenStatus ? .green : .purple)
        
        Button(role: .destructive) {
            viewModel.selectedIssue = issue
            showingDeleteIssueConfirmation = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    func handleChange() {
        viewModel.runSearch()
        issues.nsPredicate = viewModel.predicate
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
