//
//  IssuesListView.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct IssuesListView: View {
    @State private var selectedIssue: Issue?
    @State private var showingAddIssueView = false
    @State private var showingEditIssueView = false
    @StateObject private var viewModel: IssuesViewModel

    init(project: Project) {
        let predicate = NSPredicate(format: "(project == %@) AND (status_ == %@)",  project, "open")
        _viewModel = StateObject(wrappedValue: IssuesViewModel(project: project, predicate: predicate))
    }
    
    var body: some View {
        NavigationView {
            FilterIssuesList(selection: $selectedIssue, predicate: viewModel.predicate) { issue in
                IssueRow(issue: issue)
                    .tag(issue)
                    .contextMenu {
                        contextMenuButtons(issue: issue)
                    }
            }
            .safeAreaInset(edge: .bottom) {
                Picker("Issue status", selection: $viewModel.searchIssueStatus) {
                    ForEach(Issue.Status.allCases) { status in
                        Text(status.label)
                            .tag(status)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                
            }
            .frame(minWidth: 250)
            .navigationTitle(viewModel.project.name)
            .onDeleteCommand(perform: deleteCommand)
            .toolbar {
                toolbarItems
            }
            
            if let selectedIssue {
                IssueDetail(issue: selectedIssue)
            } else {
                Text("Select an issue.")
            }
        }
        .searchable(text: $viewModel.searchText)
        .onChange(of: viewModel.searchText) { _ in
            viewModel.runSearch()
        }
        .onChange(of: viewModel.searchIssueStatus) { _ in
            viewModel.runSearch()
        }
        .sheet(isPresented: $showingAddIssueView) {
            AddIssueView(project: viewModel.project)
        }
        .sheet(isPresented: $showingEditIssueView) {
            if let selectedIssue {
                EditIssueView(issue: selectedIssue)
            }
        }
        .focusedValue(\.selectedIssue, $selectedIssue) // focusedObject should be here.
        .focusedValue(\.deleteIssueAction, viewModel.deleteIssue)
        // TODO: This looks ugly. Search for something else.
        .focusedValue(\.addIssueAction) {
            showingAddIssueView = true
        }
        .focusedValue(\.editIssueAction) {
            showingEditIssueView = true
        }
        .focusedValue(\.setIssueStatusAction) {
            if let selectedIssue {
                viewModel.toggleStatus(selectedIssue)
            }
        }
    }
}

private extension IssuesListView {
    func deleteCommand() {
        if let selectedIssue {
            self.selectedIssue = nil
            viewModel.deleteIssue(selectedIssue)
        }
    }
}

// MARK: Subviews
private extension IssuesListView {
    @ViewBuilder
    func contextMenuButtons(issue: Issue) -> some View {
        Button {
            selectedIssue = issue
            showingEditIssueView = true
        } label: {
            Label("Edit", systemImage: SFSymbol.pencil.rawValue)
        }
        
        Button {
            if issue.status == .open {
                viewModel.closeIssue(issue)
                selectedIssue = nil
            } else {
                viewModel.openIssue(issue)
            }
        } label: {
            if issue.status == .open {
                Label("Close issue", systemImage: SFSymbol.bookClosed.rawValue)
            } else {
                Label("Open issue", systemImage: SFSymbol.book.rawValue)
            }
        }

        Divider()
        
        Button(role: .destructive) {
            selectedIssue = issue
            deleteCommand()
        } label: {
            Label("Delete", systemImage: SFSymbol.trash.rawValue)
        }
    }
    
    var toolbarItems: some View {
        HStack {
            Button {
                showingAddIssueView = true
            } label: {
                Label("Add issue", systemImage: SFSymbol.plus.rawValue)
            }
            
            Button(role: .destructive, action: deleteCommand) {
                Label("Delete", systemImage: SFSymbol.trash.rawValue)
            }
            .disabled(selectedIssue == nil)
        }
    }
}

struct IssuesListView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    static var project = {
        let project = Project.example(context: viewContext)
        project.addToIssues(Issue(name: "testing", issueDescription: "some description", priority: .low, tags: [], context: viewContext))
        return project
    }()
    
    static var previews: some View {
        IssuesListView(project: project)
    }
}
