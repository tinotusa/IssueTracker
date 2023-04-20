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
    @StateObject private var viewModel = AddProjectViewModel()
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    
    var body: some View {
        NavigationStack {
            List {
                Section("Project name") {
                    CustomTextField("Project name",text: $viewModel.projectName)
                        .isMandatoryFormField(true)
                        .textFieldInputValidationHandler(viewModel.validateProjectName)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
                
                Section("Start date") {
                    DatePicker(
                        "Start date",
                        selection: $viewModel.dateStarted,
                        in: ...Date(),
                        displayedComponents: [.date]
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.customBackground)
                    .labelsHidden()
                }
            }
            .listStyle(.plain)
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add project", action: addProject)
                    .disabled(!viewModel.isValidForm)
            }
            .sheet(item: $errorWrapper) { error in
                ErrorView(errorWrapper: error)
            }
            .background(Color.customBackground)
            .toolbarBackground(Color.customBackground)
            .navigationTitle("New project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: dismiss.callAsFunction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add project", action: addProject)
                        .disabled(!viewModel.isValidForm)
                }
            }
        }
    }
}

private extension AddProjectView {
    func addProject() {
        Task  {
            do {
                try await persistenceController.addProject(name: viewModel.projectName, dateStarted: viewModel.dateStarted)
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
