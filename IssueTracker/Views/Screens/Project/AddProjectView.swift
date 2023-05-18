//
//  AddProjectView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI
import Combine
import PhotosUI

struct LabeledForm<Content: View>: View {
    let title: LocalizedStringKey
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.footnote.smallCaps())
                .foregroundColor(.secondary)
            content()
        }
    }
}

struct AddProjectView: View {
    @State private var errorWrapper: ErrorWrapper?
    @State private var projectData = ProjectProperties()
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    LabeledForm(title: "Name") {
                        CustomTextField("Project name",text: $projectData.name)
                            .isMandatoryFormField(true)
                            .textFieldInputValidationHandler(ProjectProperties.validateProjectName)
                            .accessibilityIdentifier("AddProjectView-projectName")
                    }
                    
                    LabeledForm(title: "Start date") {
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
                }
                .padding()
                .navigationTitle("New project")
                .accessibilityIdentifier("projectForm")
                .sheet(item: $errorWrapper) { error in
                    ErrorView(errorWrapper: error)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close", action: dismiss.callAsFunction)
                            .accessibilityIdentifier("AddProjectView-closeButton")
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add", action: addProject)
                            .disabled(!projectData.isValidForm())
                            .accessibilityIdentifier("AddProjectView-addProjectToolbarButton")
                    }
                }
            }
        }
        .interactiveDismissDisabled(projectData.isValidForm())
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
