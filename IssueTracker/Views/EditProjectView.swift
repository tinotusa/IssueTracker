//
//  EditProjectView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI

struct EditProjectView: View {
    @ObservedObject private(set) var project: Project
    private let initialProjectData: ProjectProperties
    
    @State private var projectProperties = ProjectProperties()
    @State private var showingHasChangesConfirmationDialog = false
    @State private var errorWrapper: ErrorWrapper?

    @EnvironmentObject private var persistenceController: PersistenceController
    @Environment(\.dismiss) private var dismiss
    
    init(project: Project) {
        _project = ObservedObject(wrappedValue: project)
        initialProjectData = project.projectProperties
    }
    
    var body: some View {
        NavigationStack {
            List {
                Group {
                    Section("Project name") {
                        TextField("Project name", text: $projectProperties.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Section("Start date") {
                        DatePicker(
                            "Project start date",
                            selection: $projectProperties.startDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    ProminentButton("Save changes", action: saveChanges)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .disabled(!canSave)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
            }
            .onAppear {
                projectProperties = project.projectProperties
            }
            .listStyle(.plain)
            .navigationTitle("Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save", action: saveChanges)
                        .disabled(!canSave)
                }
            }
            .background(Color.customBackground)
            .confirmationDialog("Changes not saved.", isPresented: $showingHasChangesConfirmationDialog) {
                Button("Don't save changes", role: .destructive, action: dismiss.callAsFunction)
            } message: {
                Text("You have changes that haven't been saved.")
            }
        }
    }
}

// MARK: - Functions
private extension EditProjectView {
    var canSave: Bool {
        let projectHasChange = initialProjectData != projectProperties
        let hasValidInput = projectProperties.isValidForm()
        return projectHasChange && hasValidInput
    }
    
    func cancel() {
        let hasChanges = initialProjectData != projectProperties
        if hasChanges {
            showingHasChangesConfirmationDialog = true
            return
        }
        dismiss()
    }
    
    func saveChanges() {
        Task {
            do {
                try await persistenceController.updateProject(project, projectData: projectProperties)
                dismiss()
            } catch {
                errorWrapper = ErrorWrapper(error: error, message: "Try to save again.")
            }
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    static var previews: some View {
        NavigationStack {
            EditProjectView(project: .example)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(PersistenceController.preview)
        }
    }
}
