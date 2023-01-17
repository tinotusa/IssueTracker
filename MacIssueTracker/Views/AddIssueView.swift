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
            
            HStack {
                Button("Add issue") {
                    viewModel.addIssue()
                    dismiss()
                }
                Button("Close") {
                    dismiss()
                }
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 200)
    }
}

struct AddIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    static var project = Project.example(context: viewContext)
    
    static var previews: some View {
        AddIssueView(project: project)
    }
}
