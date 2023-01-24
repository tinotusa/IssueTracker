//
//  IssuesListView.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct IssuesListView: View {
    let project: Project
    @State private var selectedIssue: Issue?
    @State private var showingAddIssueView = false
    @State private var showingEditIssueView = false
    @StateObject private var viewModel: IssuesViewModel
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated_, order: .forward)])
    private var issues: FetchedResults<Issue>
    
    init(project: Project) {
        self.project = project
        let predicate = NSPredicate(format: "(project == %@) AND (status_ == %@)",  project, "open")
        _issues = FetchRequest(
            sortDescriptors: [.init(\.dateCreated_, order: .forward)],
            predicate: NSPredicate(format: "(project == %@) AND (status_ == %@)",  project, "open"))
        _viewModel = StateObject(wrappedValue: IssuesViewModel(project: project, predicate: predicate))
    }
    
    var body: some View {
        NavigationView {
            List(selection: $selectedIssue) {
                Text("Issues")
                    .foregroundColor(.secondary)
                ForEach(issues) { issue in
                    NavigationLink(
                        destination: IssueDetail(issue: issue),
                        tag: issue,
                        selection: $selectedIssue
                    ) {
                        IssueRow(issue: issue)
                    }
                    .contextMenu {
                        contextMenuButtons(issue: issue)
                    }
                }
            }
            .frame(minWidth: 250)
            .navigationTitle(project.name)
            .onDeleteCommand(perform: deleteCommand)
            .toolbar {
                toolbarItems
            }
            
            Text("Select an issue.")
        }
        .sheet(isPresented: $showingAddIssueView) {
            AddIssueView(project: project)
        }
        .sheet(isPresented: $showingEditIssueView) {
            if let selectedIssue {
                EditIssueView(issue: selectedIssue)
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
