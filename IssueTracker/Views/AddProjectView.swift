//
//  AddProjectView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI
import Combine

struct AddProjectView: View {
    @State private var projectName = ""
    @State private var dateStarted: Date = .now
    @State private var errorWrapper: ErrorWrapper?
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    
    var body: some View {
        NavigationStack {
            List {
                Section("Project name") {
                    TextField("Project name", text: $projectName)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add project") {
                    addProject()
                }
                .disabled(addButtonDisabled)
            }
            .sheet(item: $errorWrapper) { error in
                ErrorView(errorWrapper: error)
            }
            .background(Color.customBackground)
            .toolbarBackground(Color.customBackground)
            .navigationTitle("New project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add project") {
                        addProject()
                    }
                    .disabled(addButtonDisabled)
                }
            }
        }
    }
}

private extension AddProjectView {
    func addProject() {
        Task  {
            do {
                try await persistenceController.addProject(name: projectName, dateStarted: dateStarted)
                dismiss()
            } catch {
                errorWrapper = ErrorWrapper(error: error, message: "Failed to add project. Try again.")
            }
        }
    }
    
    func filterName(name: String) {
        let filteredName = Project.filterName(name)
        if filteredName != projectName {
            projectName = filteredName
        }
    }
    
    var addButtonDisabled: Bool {
        let projectName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        return projectName.isEmpty
    }
    
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView()
            .environment(
                \.managedObjectContext,
                 PersistenceController.preview.container.viewContext
            )
            .environmentObject(PersistenceController.preview)
    }
}
