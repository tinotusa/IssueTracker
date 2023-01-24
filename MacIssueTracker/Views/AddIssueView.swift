//
//  AddIssueView.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI
enum InputField: Hashable {
    case name
    case description
    case priority
    case tags
}

struct AddIssueView: View {
    @StateObject private var viewModel: AddIssueViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: InputField?
    init(project: Project) {
        _viewModel = StateObject(wrappedValue: AddIssueViewModel(project: project))
    }
    
    var body: some View {
        Form {
            TextField("Issue name", text: $viewModel.name)
                .focused($focusedField, equals: .name)
                .onSubmit {
                    focusedField = .description
                }
//            Section("Description") {
                TextField("Description", text: $viewModel.description)
                    .frame(minHeight: 100)
                    .focused($focusedField, equals: .description)
                    .onSubmit {
                        focusedField = .priority
                    }
//            }
            Picker("Priority", selection: $viewModel.priority) {
                ForEach(Issue.Priority.allCases) { priority in
                    Text(priority.title)
                }
            }
            .pickerStyle(.radioGroup)
            .focused($focusedField, equals: .priority)
            Section("Tags") {
                TagSearchView(selectedTags: $viewModel.tags)
                    .focused($focusedField, equals: .tags)
            }
            HStack {
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                Button("Add issue") {
                    viewModel.addIssue()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
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
