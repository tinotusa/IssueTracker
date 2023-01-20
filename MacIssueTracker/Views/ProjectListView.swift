//
//  ProjectListView.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct ProjectListView: View {
    @FetchRequest(sortDescriptors: [])
    private var projects: FetchedResults<Project>
    
    @State private var showingAddProjectView = false
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List {
            Text("Projects")
                .foregroundColor(.secondary)
            ForEach(projects) { project in
                NavigationLink(project.name, destination: IssuesListView(project: project))
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

struct ProjectListView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    
    static var previews: some View {
        ProjectListView()
            .environment(\.managedObjectContext, viewContext)
    }
}
