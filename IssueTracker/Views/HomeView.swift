//
//  HomeView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

struct HomeView: View {
    @State private var showingDeleteConfirmation = false
    @State private var selectedProject: Project?
    @State private var showingAddProjectView = false
    @State private var errorWrapper: ErrorWrapper?
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistenceController: PersistenceController
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var projects: FetchedResults<Project>
    
    var body: some View {
        NavigationStack {
            List {
                if projects.isEmpty {
                    Text("🗒\nNo projects.\nAdd one to start tracking.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.customSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.customBackground)
                } else {
                    ForEach(projects) { project in
                        NavigationLink(value: project) {
                            ProjectRowView(project: project)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                selectedProject = project
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                    .onDelete(perform: deleteProject)
                    .listRowBackground(Color.customBackground)
                    .listRowSeparator(.hidden)
                }
            }
            .refreshable {
                viewContext.refreshAllObjects()
            }
            .navigationTitle("Projects")
            .toolbarBackground(Color.customBackground)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingAddProjectView = true
                    } label: {
                        Label("Add project", systemImage: "square.and.pencil")
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                ToolbarItem {
                    Button {
                        // TODO: make sheet appear?
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .listStyle(.plain)
            .bodyStyle()
            .sheet(item: $errorWrapper) { error in
                ErrorView(errorWrapper: error)
            }
            .sheet(isPresented: $showingAddProjectView) {
                AddProjectView()
                    .sheetWithIndicator()
            }
            .sheet(item: $selectedProject) { project in
                EditProjectView(project: project, initialProjectData: ProjectProperties(name: project.wrappedName, startDate: project.wrappedStartDate))
                    .sheetWithIndicator()
            }
            .background(Color.customBackground)
            .navigationDestination(for: Project.self) { project in
                IssuesListView(project: project)
            }
            .confirmationDialog("Delete project", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    guard let selectedProject else {
                        return
                    }
                    Task {
                        do {
                            try await persistenceController.deleteObject(selectedProject)
                            self.selectedProject = nil
                        } catch {
                            errorWrapper = ErrorWrapper(error: error, message: "Failed to delete the project.")
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this project?")
            }
        }
    }
}

private extension HomeView {
    func deleteProject(offsets indexSet: IndexSet) {
        Task {
            for index in indexSet {
                do {
                    try await persistenceController.deleteObject(projects[index])
                } catch {
                    errorWrapper = .init(error: error, message: "Failed to delete project.")
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(PersistenceController.preview)
    }
}
