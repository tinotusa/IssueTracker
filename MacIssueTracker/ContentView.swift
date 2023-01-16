//
//  ContentView.swift
//  MacIssueTracker
//
//  Created by Tino on 16/1/2023.
//

import SwiftUI

struct AddProjectView: View {
    @StateObject private var viewModel = AddProjectViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            TextField("Name", text: $viewModel.projectName)
            Button("Add project") {
                viewModel.addProject()
                dismiss()
            }
            Button("Close") {
                dismiss()
            }
        }
        .padding()
        .navigationTitle("Add new project")
        .frame(minWidth: 300, minHeight: 300)
        
    }
}

struct ProjectListView: View {
    @FetchRequest(sortDescriptors: [])
    private var projects: FetchedResults<Project>
    
    @State private var showingAddProjectView = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List {
            if projects.isEmpty {
                Text("No projects. Add a project to track.")
            } else {
                Text("Projects")
                    .foregroundColor(.secondary)
                
                ForEach(projects) { project in
                    NavigationLink(project.name, destination: IssuesListView(project: project))
                }
            }
        }
        .sheet(isPresented: $showingAddProjectView) {
            AddProjectView()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddProjectView = true
                } label: {
                    Label("Add Project", systemImage: "plus")
                }
            }
        }
    }
}


struct AddIssueView: View {
    @StateObject private var viewModel: AddIssueViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(project: Project) {
        _viewModel = StateObject(wrappedValue: AddIssueViewModel(project: project))
    }
    
    var body: some View {
        Form {
            TextField("Issue name", text: $viewModel.name)
            Section("Description") {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
            }
            Picker("Priority", selection: $viewModel.priority) {
                ForEach(Issue.Priority.allCases) { priority in
                    Text(priority.title)
                }
            }
            .pickerStyle(.radioGroup)
            
            HStack {
                Button("Add issue") {
                    viewModel.addIssue()
                    dismiss()
                }
                Button("Close") {
                    dismiss()
                }
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 200)
    }
}
struct IssueDetail: View {
    @ObservedObject var issue: Issue
    
    var body: some View {
        VStack {
            Text(issue.name)
            Text(issue.issueDescription)
            Text(issue.priority.title)
            Text("Started: \(issue.dateCreated.formatted())")
        }
    }
}

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

struct HomeView: View {
    @State private var searchText = ""
    var body: some View {
        NavigationView {
            ProjectListView()
                .searchable(text: $searchText)
//                .frame(minWidth: 700, minHeight: 300)
            Text("Select a project.")
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    #if os(macOS)
                    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                    #endif
                } label: {
                    Label("Show sidebar", systemImage: "sidebar.leading")
                }
            }
        }
    }
}
struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.projectsPreview.container.viewContext)
    }
}
