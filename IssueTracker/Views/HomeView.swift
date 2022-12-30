//
//  HomeView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = HomeViewModel()
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated_, order: .reverse)])
    private var projects: FetchedResults<Project>
    
    var body: some View {
        NavigationStack {
            VStack {
                header
                ScrollView {
                    VStack(alignment: .leading) {
                        if projects.isEmpty {
                            Text("🗒\nNo projects.\nAdd one to start tracking.")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.customSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(projects) { project in
                                NavigationLink(value: project) {
                                    ProjectRowView(project: project)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .bodyStyle()
                
                .sheet(isPresented: $viewModel.showingAddProjectView) {
                    AddProjectView()
                        .environment(\.managedObjectContext, viewContext)
                        .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $viewModel.showingEditProjectView) {
                    EditProjectsView()
                        .environment(\.managedObjectContext, viewContext)
                }
                .sheet(isPresented: $viewModel.showingDeleteProjectView) {
                    DeleteProjectView()
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .padding()
            .background(Color.customBackground)
            .navigationDestination(for: Project.self) { project in
                Text("Project view")
            }
        }
    }
}

private extension HomeView {
    var header: some View {
        HStack {
            Text(viewModel.title)
                .titleStyle()
            Spacer()
            Menu {
                Button {
                    viewModel.showingAddProjectView = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
                Button {
                    viewModel.showingEditProjectView = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                Button {
                    viewModel.showingDeleteProjectView = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .bodyStyle()
            }
            
            Button {
                // TODO: make sheet appear?
            } label: {
                Image(systemName: "gear")
                    .bodyStyle()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(
                \.managedObjectContext,
                 PersistenceController.projectsPreview.container.viewContext
            )
    }
}
