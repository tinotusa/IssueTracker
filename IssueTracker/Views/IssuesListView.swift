//
//  IssuesListView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI
import CoreData

struct IssuesListView: View {
    @ObservedObject private(set) var project: Project
    @State private var selectedIssue: Issue?
    @State private var issuesViewState: IssuesViewState?
    @State private var showingDeleteIssueConfirmation = false
    @State private var errorWrapper: ErrorWrapper?
    
    @State private var searchState = SearchState()
    @State private var sortState = SortState()
    
    @FetchRequest(sortDescriptors: [])
    private var issues: FetchedResults<Issue>
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    
    init(project: Project) {
        _project = ObservedObject(wrappedValue: project)
        _issues = FetchRequest(
            sortDescriptors: [.init(\.dateCreated, order: .forward)],
            predicate: NSPredicate(format: "(project == %@) AND (status == %@)",  project, "open")
        )
    }
    
    var body: some View {
        List {
            if issues.isEmpty {
                Text("No issues.")
                    .font(.headline)
                    .listRowBackground(Color.customBackground)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(issues) { issue in
                    NavigationLink(value: issue) {
                        IssueRowView(issue: issue)
                    }
                    .swipeActions(edge: .leading) {
                        changeIssueStatusButton(issue: issue)
                    }
                    .listRowBackground(Color.customBackground)
                }
                .onDelete(perform: deleteIssue)
            }
        }
        .navigationDestination(for: Issue.self) { issue in
            IssueDetail(issue: issue)
        }
        .sheet(item: $errorWrapper) { error in
            ErrorView(errorWrapper: error)
        }
        .listStyle(.plain)
        .searchable(text: $searchState.searchText)
        .searchScopes($searchState.searchScope) {
            ForEach(SearchState.SearchScopes.allCases) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .onChange(of: searchState.searchText) { _ in
            handleChange()
        }
        .onChange(of: searchState.searchScope) { _ in
            handleChange()
        }
        .onChange(of: searchState.searchIssueStatus) { _ in
            handleChange()
        }
        .navigationBarTitle(searchState.searchIssueStatus == .open ? "Open issues" : "Closed issues")
        .toolbarBackground(Color.customBackground, for: .navigationBar, .bottomBar) // this doesn't seem to change the bottom bar at all.
        .background(Color.customBackground)
        .sheet(item: $issuesViewState) { state in
            Group {
                switch state {
                case .showingAddIssueView:
                    AddIssueView(project: project)
                        .environment(\.managedObjectContext, viewContext)
                case .showingEditTagsView:
                    TagsEditView()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .sheetWithIndicator()
        }
        .toolbar {
            toolbarItems
        }
        .confirmationDialog("Delete issue", isPresented: $showingDeleteIssueConfirmation) {
            Button(role: .destructive) {
                // TODO: Remove code from ui (make a func)
                guard let selectedIssue else {
                    return
                }
                Task {
                    do {
                        try await persistenceController.deleteObject(selectedIssue)
                    } catch {
                        errorWrapper = .init(error: error, message: "Failed to delete issue.")
                    }
                }
            } label: {
                Text("Delete")
            }
        } message: {
            Text("Are you sure you want to delete this issue?")
        }
    }
}

// MARK: - Views
private extension IssuesListView {
    @ViewBuilder
    func labelFor(_ sortOrder: SortOrder, title: LocalizedStringKey) -> some View {
        if sortState.sortOrder == sortOrder {
            Label(title, systemImage: SFSymbol.checkmark)
        } else {
            Text(title)
        }
    }
    
    var sortBySection: some View {
        Section("Sort by") {
            ForEach(SortState.SortType.allCases) { sortType in
                Button {
                    sortState.sortType = sortType
                } label: {
                    if sortState.sortType == sortType {
                        Label(sortType.title, systemImage: SFSymbol.checkmark)
                    } else {
                        Text(sortType.title)
                    }
                }
            }
        }
    }
    
    var sortTypeSection: some View {
        Section {
            switch sortState.sortType {
            case .date:
                Button {
                    sortState.setSortOrder(to: .reverse)
                    issues.sortDescriptors = [sortState.sortDescriptor]
                } label: {
                    labelFor(.reverse, title: "Newest first")
                }
                Button {
                    sortState.setSortOrder(to: .forward)
                    issues.sortDescriptors = [sortState.sortDescriptor]
                } label: {
                    labelFor(.forward, title: "Oldest first")
                }
            case .priority, .title:
                Button {
                    sortState.setSortOrder(to: .forward)
                    issues.sortDescriptors = [sortState.sortDescriptor]
                } label: {
                    labelFor(.forward, title: "Ascending")
                }
                Button {
                    sortState.setSortOrder(to: .reverse)
                    issues.sortDescriptors = [sortState.sortDescriptor]
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
                issuesViewState = .showingEditTagsView
            }
        }
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                searchState.searchIssueStatus = searchState.searchIssueStatus == .open ? .closed : .open
            } label: {
                Label(
                    "Issue status",
                    systemImage: searchState.searchIssueStatus == .open ? SFSymbol.trayAndArrowDownFill : SFSymbol.trayAndArrowUpFill
                )
            }
            
            Button {
                issuesViewState = .showingAddIssueView
            } label: {
                Label("Add Issue", systemImage: SFSymbol.plus)
            }
        }
    }
    
    func changeIssueStatusButton(issue: Issue) -> some View {
        Button {
            Task {
                do {
                    switch issue.wrappedStatus {
                    case .closed:
                        try await persistenceController.setIssueStatus(for: issue, to: .open)
                    case .open:
                        try await persistenceController.setIssueStatus(for: issue, to: .closed)
                    }
                } catch {
                    errorWrapper = .init(error: error, message: "Failed to change issue status.")
                }
            }
        } label: {
            Label(
                issue.isOpenStatus ? "Close issue" : "Open Issue",
                systemImage: issue.isOpenStatus ? SFSymbol.trayAndArrowDownFill : SFSymbol.trayAndArrowUpFill
            )
        }
        .tint(issue.isOpenStatus ? .green : .purple)
    }
}

// MARK: - Functions
private extension IssuesListView {
    enum IssuesViewState: Identifiable {
        case showingAddIssueView
        case showingEditTagsView
        
        var id: Self { self }
    }


    func deleteIssue(offsets indexSet: IndexSet) {
        for index in indexSet {
            let issue = issues[index]
            Task {
                do {
                    try await persistenceController.deleteObject(issue)
                } catch {
                    errorWrapper = .init(error: error, message: "Failed to delete issue.")
                }
            }
        }
    }
    
    func handleChange() {
        searchState.runSearch(project)
        issues.nsPredicate = searchState.predicate
    }
}

struct IssuesView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        NavigationStack {
            IssuesListView(project: .example)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(PersistenceController.preview)
        }
    }
}
