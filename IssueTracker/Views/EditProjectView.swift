//
//  EditProjectView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI

struct EditProjectView: View {
    @ObservedObject private(set) var project: Project
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditProjectViewModel
    
    init(project: Project) {
        _project = ObservedObject(wrappedValue: project)
        _viewModel = StateObject(wrappedValue: EditProjectViewModel(project: project))
    }
    
    var body: some View {
        NavigationStack {
            List {
                Group {
                    Section("Project name") {
                        TextField("Project name", text: $viewModel.projectName)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Section("Start date") {
                        DatePicker(
                            "Project start date",
                            selection: $viewModel.startDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    ProminentButton("Save changes") {
                        _ = viewModel.save()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(!viewModel.projectHasChanges)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
            }
            .listStyle(.plain)
            .navigationTitle("Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewModel.cancel()
                        if !viewModel.showingHasChangesConfirmationDialog {
                            dismiss()
                        }
                    } label: {
                        Text("Cancel")
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        _ = viewModel.save()
                        dismiss()
                    }
                    .disabled(!viewModel.projectHasChanges)
                }
            }
            .background(Color.customBackground)
            .confirmationDialog("Changes not saved.", isPresented: $viewModel.showingHasChangesConfirmationDialog) {
                Button("Don't save changes", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("You have changes that haven't been saved.")
            }
        }
    }
}
struct EditProjectView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    static var previews: some View {
        NavigationStack {
            EditProjectView(project: .example(context: viewContext))
        }
    }
}
