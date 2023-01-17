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
    
    init(project: Project) {
        self.project = project
        _issues = FetchRequest(
            sortDescriptors: [.init(\.dateCreated_, order: .forward)],
            predicate: NSPredicate(format: "(project == %@) AND (status_ == %@)",  project, "open"))
    }
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            if issues.isEmpty {
                Text("No issues. Add an issue for this project.")
            } else {
                List {
                    Text("Issues")
                        .foregroundColor(.secondary)
                    if issues.isEmpty {
                        Text("No issues. Add an issue for this project.")
                    } else {
                        ForEach(issues) { issue in
                            NavigationLink(destination: IssueDetail(issue:issue)) {
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
                            .swipeActions {
                                Button {
                                    // no action
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingAddIssueView) {
                    AddIssueView(project: project)
                }
                .navigationTitle(project.name)
                .toolbar {
                    ToolbarItem {
                        Button {
                            showingAddIssueView = true
                        } label: {
                            Label("Add issue", systemImage: "plus")
                        }
                    }
                }
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
