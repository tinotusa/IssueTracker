//
//  EditIssueView.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import SwiftUI

struct EditIssueView: View {
    @ObservedObject private(set) var issue: Issue
    @ObservedObject private var issueCopy: Issue
    @State private var showingCancelDialog = false
    @State private var selectedTags: Set<Tag> = []
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistenceController: PersistenceController
    
    init(issue: Issue) {
        self.issue = issue
        issueCopy = Issue.copyIssue(issue: issue)
        _selectedTags = State(wrappedValue: issue.wrappedTags)
    }
    
    var body: some View {
        List {
            Group {
                Section("Issue name") {
                    TextField("Issue name", text: $issueCopy.wrappedName)
                        .textFieldStyle(.roundedBorder)
                }
                Section("Description") {
                    TextField("Issue Description", text: $issueCopy.wrappedIssueDescription, axis: .vertical)
                        .lineLimit(3...)
                        .textFieldStyle(.roundedBorder)
                }
                Section("Priority") {
                    Picker("Issue priority", selection: $issueCopy.wrappedPriority) {
                        ForEach(Issue.Priority.allCases) { priority in
                            Text(priority.title)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Tags") {
                    TagSelectionView(selection: $selectedTags)
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
        .persistenceErrorAlert(isPresented: $persistenceController.showingError, presenting: $persistenceController.persistenceError)
        .safeAreaInset(edge: .bottom) {
            ProminentButton("Save Changes") {
                persistenceController.copyIssue(from: issueCopy, to: issue, withTags: selectedTags)
            }
            .disabled(issueCopy != issue)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if issueCopy != issue {
                        showingCancelDialog = true
                    } else {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    persistenceController.copyIssue(from: issueCopy, to: issue, withTags: selectedTags)
                }
                .disabled(issueCopy != issue)
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
    static var previews: some View {
        NavigationStack {
            EditIssueView(issue: .example)
                .environmentObject(PersistenceController())
        }
    }
}
