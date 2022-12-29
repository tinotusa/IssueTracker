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
    
    @StateObject private var viewModel = DeleteProjectViewModel()
    
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
                    if projects.isEmpty {
                        Text("No projects to delete")
                    } else {
                        ForEach(projects) { project in
                            Button {
                                viewModel.selectedProject = project
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
        }
        .padding()
        .bodyStyle()
        .background(Color.customBackground)
        .confirmationDialog("Delete project", isPresented: $viewModel.showingDeleteProjectDialog, presenting: viewModel.selectedProject) { _ in
            Button("Delete", role: .destructive) {
                _ = viewModel.deleteProject()
            }
        } message: { project in
            Text("Are you sure you want to delete \(project.name)")
        }
    }
}

struct DeleteProjectView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteProjectView()
            .environment(\.managedObjectContext, PersistenceController.projectsPreview.container.viewContext)
    }
}
