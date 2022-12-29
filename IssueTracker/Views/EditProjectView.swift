//
//  EditProjectView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI

struct EditProjectView: View {
    @ObservedObject var project: Project
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditProjectViewModel
    
    init(project: Project) {
        _project = ObservedObject(wrappedValue: project)
        _viewModel = StateObject(wrappedValue: EditProjectViewModel(project: project))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                PlainButton("Cancel") {
                    viewModel.cancel()
                    if !viewModel.showingHasChangesConfirmationDialog {
                        dismiss()
                    }
                }
                Spacer()
                PlainButton("Save") {
                    _ = viewModel.save()
                    dismiss()
                }
                .disabled(!viewModel.projectHasChanges)
            }
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Editing Project")
                        .titleStyle()
                    Text("Project name:")
                    CustomTextField("Project name", text: $viewModel.projectName)
                    
                    Text("Project start date:")
                    DatePicker("Project start date", selection: $viewModel.startDate, displayedComponents: [.date])
                        .padding(.bottom)
                    ProminentButton("Save changes") {
                        _ = viewModel.save()
                        dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(!viewModel.projectHasChanges)
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .bodyStyle()
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
struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: .example(context: PersistenceController.empty.container.viewContext))
    }
}
