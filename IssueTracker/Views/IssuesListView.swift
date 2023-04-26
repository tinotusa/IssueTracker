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
    
    @State private var sheetState: SheetState?
    @State private var showingDeleteProjectConfirmation = false
    @State private var errorWrapper: ErrorWrapper?
    @State private var issueStatus = Issue.Status.open
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
            Picker("Issue status", selection: $issueStatus) {
                ForEach(Issue.Status.allCases) { status in
                    Text(status.label)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.customBackground)
            
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
        .onChange(of: issueStatus, perform: updateIssuesPredicate)
        .navigationTitle("Issues")
        .toolbarBackground(Color.customBackground, for: .navigationBar, .bottomBar) // this doesn't seem to change the bottom bar at all.
        .background(Color.customBackground)
        .sheet(item: $sheetState) { state in
            Group {
                switch state {
                case .addView:
                    AddIssueView(project: project)
                        .environment(\.managedObjectContext, viewContext)
                case .editTags:
                    TagsEditView()
                        .environment(\.managedObjectContext, viewContext)
                case .editProject:
                    EditProjectView(project: project)
                }
            }
            .sheetWithIndicator()
        }
        .toolbar {
            toolbarItems
        }
        .confirmationDialog("Delete project", isPresented: $showingDeleteProjectConfirmation) {
            Button("Delete", role: .destructive, action: deleteProject)
        } message: {
            Text("Are you sure you want to delete this project?")
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
                Button(action: showEditProjectView) {
                    Label("Edit project", systemImage: SFSymbol.infoCircle)
                }
                Menu {
                    sortBySection
                    sortTypeSection
                } label: {
                    Label("Sort by", systemImage: SFSymbol.arrowUpArrowDown)
                }
                Button(action: showEditTagsView) {
                    Label("Edit tags", systemImage: SFSymbol.tag)
                }
                Button(role: .destructive, action: showDeleteConfirmation) {
                    Label("Delete project", systemImage: SFSymbol.trash)
                }
            } label: {
                Label("Options", systemImage: SFSymbol.ellipsisCircle)
            }
        }
        
        ToolbarItemGroup(placement: .bottomBar) {
            Button(action: showAddIssueView) {
                Label("Add Issue", systemImage: SFSymbol.plusCircleFill)
                    .labelStyle(.titleAndIcon)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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
    enum SheetState: Identifiable {
        case addView
        case editTags
        case editProject
        
        var id: Self { self }
    }
    
    func showDeleteConfirmation() {
        showingDeleteProjectConfirmation = true
    }
    
    func showEditProjectView() {
        sheetState = .editProject
    }
    
    func showAddIssueView() {
        sheetState = .addView
    }
    
    func showEditTagsView() {
        sheetState = .editTags
    }
    
    func updateIssuesPredicate(to issueStatus: Issue.Status) {
        let format = "project == %@ AND status == %@"
        issues.nsPredicate = .init(format: format, project, issueStatus.rawValue)
    }
    
    func deleteProject() {
        Task {
            do {
                try await persistenceController.deleteObject(project)
                dismiss()
            } catch {
                errorWrapper = .init(error: error, message: "Failed to delete project.")
            }
        }
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
