//
//  EditIssueView.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import SwiftUI

struct EditIssueView: View {
    @ObservedObject private(set) var issue: Issue
    
    @State private var showingCancelDialog = false
    
    @StateObject private var viewModel: EditIssueViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    init(issue: Issue) {
        self.issue = issue
        _viewModel = StateObject(wrappedValue: EditIssueViewModel(issue: issue))
    }
    
    var body: some View {
        List {
            Group {
                Section("Issue name:") {
                    TextField("Issue name", text: $viewModel.issueCopy.wrappedName)
                        .textFieldStyle(.roundedBorder)
                }
                Section("Description") {
                    TextField("Issue Description", text: $viewModel.issueCopy.wrappedIssueDescription, axis: .vertical)
                        .lineLimit(3...)
                        .textFieldStyle(.roundedBorder)
                }
                Section("Priority") {
                    Picker("Issue priority", selection: $viewModel.issueCopy.wrappedPriority) {
                        ForEach(Issue.Priority.allCases) { priority in
                            Text(priority.title)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Tags") {
                    TagFilterView(selectedTags: $viewModel.selectedTags)
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.customBackground)
        }
        .listStyle(.plain)
        .background(Color.customBackground)
        .toolbarBackground(Color.customBackground)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Edit issue")
        .safeAreaInset(edge: .bottom) {
            ProminentButton("Save Changes") {
                viewModel.saveChanges()
            }
            .disabled(!viewModel.hasChanges)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if viewModel.hasChanges {
                        showingCancelDialog = true
                    } else {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.saveChanges()
                }
                .disabled(!viewModel.hasChanges)
            }
        }
        .confirmationDialog("Cancel changes", isPresented: $showingCancelDialog) {
            Button("Don't save", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You haven't saved these changes.")
        }
    }
}

struct IssueEditView_Previews: PreviewProvider {
    static let viewContext = PersistenceController.issuesPreview.container.viewContext
    
    static var previews: some View {
        NavigationStack {
            EditIssueView(issue: Issue(name: "Test issue", issueDescription: "", priority: .low, tags: [], context: viewContext))
        }
    }
}
