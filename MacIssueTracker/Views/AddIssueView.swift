//
//  AddIssueView.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct AddIssueView: View {
    @StateObject private var viewModel: AddIssueViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(project: Project) {
        _viewModel = StateObject(wrappedValue: AddIssueViewModel(project: project))
    }
    
    var body: some View {
        Form {
            TextField("Issue name", text: $viewModel.name)
            Section("Description") {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 100)
                    
            }
            Picker("Priority", selection: $viewModel.priority) {
                ForEach(Issue.Priority.allCases) { priority in
                    Text(priority.title)
                }
            }
            .pickerStyle(.radioGroup)
            Section("Tags") {
                TagSearchView(selectedTags: $viewModel.tags)
            }
            HStack {
                Button("Close") {
                    dismiss()
                }
                Button("Add issue") {
                    viewModel.addIssue()
                    dismiss()
                }
                .disabled(!viewModel.allFieldsFilled)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        
        .padding()
        .frame(minWidth: 800, minHeight: 450)
    }
}

struct AddIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    static var project = Project.example(context: viewContext)
    
    static var previews: some View {
        AddIssueView(project: project)
            .environment(\.managedObjectContext, viewContext)
    }
}
