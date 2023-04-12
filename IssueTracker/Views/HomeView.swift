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
                        .swipeActions {
                            Button(role: .destructive) {
                                selectedProject = project
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listRowBackground(Color.customBackground)
                    .listRowSeparator(.hidden)
                }
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
            .sheet(isPresented: $showingAddProjectView) {
                AddProjectView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedProject) { project in
                EditProjectView(project: project)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .background(Color.customBackground)
            .navigationDestination(for: Project.self) { project in
                IssuesView(project: project)
            }
            .confirmationDialog("Delete project", isPresented: $showingDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    guard let selectedProject else {
                        return
                    }
                    persistenceController.deleteObject(selectedProject)
                    self.selectedProject = nil
                }
            } message: {
                Text("Are you sure you want to delete this project?")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(PersistenceController())
    }
}
