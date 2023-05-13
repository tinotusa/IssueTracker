//
//  AddProjectView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI
import Combine

struct AddProjectView: View {
    @State private var errorWrapper: ErrorWrapper?
    @State private var projectData = ProjectProperties()
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    
    var body: some View {
        NavigationStack {
            List {
                Section("Project name") {
                    CustomTextField("Project name",text: $projectData.name)
                        .isMandatoryFormField(true)
                        .textFieldInputValidationHandler(ProjectProperties.validateProjectName)
                        .accessibilityIdentifier("AddProjectView-projectName")
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
                
                Section("Start date") {
                    DatePicker(
                        "Start date",
                        selection: $projectData.startDate,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.customBackground)
                    .labelsHidden()
                    .accessibilityIdentifier("datePicker")
                }
                ProminentButton("Add project", action: addProject)
                    .disabled(!projectData.isValidForm())
                    .accessibilityIdentifier("AddProjectView-addProjectButton")
            }
            .listStyle(.plain)
            .sheet(item: $errorWrapper) { error in
                ErrorView(errorWrapper: error)
            }
            .background(Color.customBackground)
            .toolbarBackground(Color.customBackground)
            .navigationTitle("New project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                        .accessibilityIdentifier("AddProjectView-closeButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add project", action: addProject)
                        .disabled(!projectData.isValidForm())
                        .accessibilityIdentifier("AddProjectView-addProjectToolbarButton")
                }
            }
        }
    }
}

// MARK: - Functions
private extension AddProjectView {
    func addProject() {
        Task  {
            do {
                try await persistenceController.addProject(projectData)
                dismiss()
            } catch {
                errorWrapper = ErrorWrapper(error: error, message: "Failed to add project. Try again.")
            }
        }
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
