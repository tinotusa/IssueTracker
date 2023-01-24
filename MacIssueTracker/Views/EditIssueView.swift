//
//  EditIssueView.swift
//  MacIssueTracker
//
//  Created by Tino on 22/1/2023.
//

import SwiftUI

struct EditIssueView: View {
    @ObservedObject var issue: Issue
    @StateObject private var viewModel: EditIssueViewModel
    @State private var showingCancelWithChangesDialog = false
    @Environment(\.dismiss) private var dismiss
    
    init(issue: Issue) {
        _issue = ObservedObject(wrappedValue: issue)
        _viewModel = StateObject(wrappedValue: EditIssueViewModel(issue: issue))
    }
    
    var body: some View {
        Form {
            TextField("Issue name", text: $viewModel.issueCopy.name)
            Section("Description") {
            TextEditor(text: $viewModel.issueCopy.issueDescription)
            }
            Picker("Priority", selection: $viewModel.issueCopy.priority) {
                ForEach(Issue.Priority.allCases) { priority in
                    Text(priority.title)
                }
            }
            
            TagSearchView(selectedTags: $viewModel.selectedTags)
            
            HStack {
                Button("Cancel") {
                    if viewModel.hasChanges {
                        showingCancelWithChangesDialog = true
                    } else {
                        dismiss()
                    }
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Button("Save") {
                    viewModel.saveChanges()
                    dismiss()
                }
                .disabled(!viewModel.hasChanges)
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(minWidth: 600, minHeight: 350)
        .confirmationDialog("Are you sure you want to cancel the changes you've made?", isPresented: $showingCancelWithChangesDialog) {
            Button("Don't save", role: .destructive) {
                dismiss()
            }
        }
    }
}

struct EditIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    
    static var previews: some View {
        EditIssueView(issue: Issue(name: "testing", issueDescription: "", priority: .low, tags: [], context: viewContext))
    }
}
