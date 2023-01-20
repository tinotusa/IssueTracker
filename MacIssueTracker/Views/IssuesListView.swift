//
//  IssuesListView.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct IssuesListView: View {
    let project: Project
    @FetchRequest(sortDescriptors: [.init(\.dateCreated_, order: .forward)])
    private var issues: FetchedResults<Issue>
    @State private var showingAddIssueView = false
    @StateObject private var viewModel: IssuesViewModel
    
    init(project: Project) {
        self.project = project
        let predicate = NSPredicate(format: "(project == %@) AND (status_ == %@)",  project, "open")
        _issues = FetchRequest(
            sortDescriptors: [.init(\.dateCreated_, order: .forward)],
            predicate: NSPredicate(format: "(project == %@) AND (status_ == %@)",  project, "open"))
        _viewModel = StateObject(wrappedValue: IssuesViewModel(project: project, predicate: predicate))
    }
    
    @State private var searchText = ""
    @State private var selectedIssues = Set<UUID>()
    @State private var selectedIssue: Issue?
    
    var body: some View {
        NavigationView {
            #warning("last on this. look up how to have nav link with list(selection:)  ")
            List(selection: $selectedIssue) {
                Text("Issues")
                    .foregroundColor(.secondary)
                ForEach(issues) { issue in
                    NavigationLink(
                        destination: IssueDetail(issue: issue),
                        tag: issue,
                        selection: $selectedIssue
                    ) {
                        VStack(alignment: .leading) {
                            Text(issue.name)
                                .lineLimit(2)
                            Group {
                                if issue.issueDescription.isEmpty {
                                    Text("No description")
                                    
                                } else {
                                    Text(issue.issueDescription)
                                        .lineLimit(2)
                                }
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        }
                    }
                    .tag(issue.id)
                }
            }
            .navigationTitle(project.name)
            .onDeleteCommand {
                deleteCommand()
            }
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
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
            
            Text("Select an issue.")
        }
        .sheet(isPresented: $showingAddIssueView) {
            AddIssueView(project: project)
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
