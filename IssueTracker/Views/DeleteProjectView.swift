//
//  DeleteProjectView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI
import CoreData

struct DeleteProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated_, order: .reverse)])
    private var projects: FetchedResults<Project>
    
    @State private var selectedProject: Project?
    @State private var showingDeleteProjectDialog = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                PlainButton("Close") {
                    dismiss()
                }
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Delete project")
                        .titleStyle()
                        .padding(.bottom)
                    
                    ForEach(projects) { project in
                        Button {
                            selectedProject = project
                            showingDeleteProjectDialog = true
                            
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                ProjectRowView(project: project)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .bodyStyle()
        .background(Color.customBackground)
        .confirmationDialog("Are you sure", isPresented: $showingDeleteProjectDialog, presenting: selectedProject) { _ in
            Button("Delete", role: .destructive) {
                deleteProject()
                dismiss()
            }
        } message: { project in
            Text("Are you sure you want to delete \(project.name)")
        }
    }
}

private extension DeleteProjectView {
    func deleteProject() {
        guard let selectedProject else {
            return
        }
        viewContext.delete(selectedProject)
        try? viewContext.save()
    }
}

struct DeleteProjectView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteProjectView()
            .environment(\.managedObjectContext, PersistenceController.projectsPreview.container.viewContext)
    }
}
