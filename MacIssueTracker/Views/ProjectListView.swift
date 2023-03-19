//
//  ProjectListView.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct ProjectListView: View {
    @State private var showingAddProjectView = false
    @State private var selectedProject: Project?
    
    @FetchRequest(sortDescriptors: [])
    private var projects: FetchedResults<Project>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List(selection: $selectedProject) {
            Text("Projects")
                .foregroundColor(.secondary)
            ForEach(projects) { project in
                NavigationLink(project.wrappedName, destination: IssuesListView(project: project))
            }
        }
        .focusedValue(\.selectedProject, $selectedProject) // TODO: - This seems like it doesn't set it.
        .sheet(isPresented: $showingAddProjectView) {
            AddProjectView()
        }
        .onAppear {
            selectedProject = nil
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

struct ProjectListView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    
    static var previews: some View {
        ProjectListView()
            .environment(\.managedObjectContext, viewContext)
    }
}
