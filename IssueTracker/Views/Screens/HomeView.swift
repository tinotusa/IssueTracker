//
//  HomeView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

struct HomeView: View {
    @State private var showingAddProjectView = false
    @State private var errorWrapper: ErrorWrapper?
    @State private var refreshID = UUID()
    @EnvironmentObject private var persistenceController: PersistenceController
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var projects: FetchedResults<Project>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if projects.isEmpty {
                    Text("🗒\nNo projects.\nAdd one to start tracking.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.customSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.customBackground)
                        .accessibilityIdentifier("noProjectsText")
                } else {
                    ForEach(projects) { project in
                        NavigationLink(value: project) {
                            ProjectRowView(project: project)
                                .accessibilityIdentifier("projectRow_\(project.wrappedName)")
                        }
                    }
                    .listRowBackground(Color.customBackground)
                    .listRowSeparator(.hidden)
                    .id(refreshID) // TODO: See if there is another way to update ui without doing this.
                }
            }
            .accessibilityIdentifier("projectsList")
            .navigationTitle("Projects")
            .toolbarBackground(Color.customBackground)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: showAddProjectView) {
                        Label("Add project", systemImage: SFSymbol.plusCircleFill)
                            .labelStyle(.titleAndIcon)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .accessibilityIdentifier("HomeView-addProjectButton")
                }
            }
            .listStyle(.plain)
            .sheet(item: $errorWrapper) { error in
                ErrorView(errorWrapper: error)
            }
            .sheet(isPresented: $showingAddProjectView) {
                AddProjectView()
                    .sheetWithIndicator()
            }
            .background(Color.customBackground)
            .navigationDestination(for: Project.self) { project in
                IssuesListView(project: project)
                    .onDisappear {
                        refreshID = UUID()
                    }
            }
        }
    }
}

// MARK: Functions
private extension HomeView {
    func showAddProjectView() {
        showingAddProjectView = true
    }
}

import CoreData
struct HomeView_Previews: PreviewProvider {
    static var context: NSManagedObjectContext {
        let viewContext = PersistenceController.preview.container.viewContext
        let _ = Project.makePreviews(count: 1)
        return viewContext
    }
    
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, context)
            .environmentObject(PersistenceController.preview)
    }
}
