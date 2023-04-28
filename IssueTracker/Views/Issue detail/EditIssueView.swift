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
    @State private var errorWrapper: ErrorWrapper?
    
    @Environment(\.editMode) private var editMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistenceController: PersistenceController
    
    init(issue: Issue) {
        self.issue = issue
        _issueCopy = ObservedObject(wrappedValue: Issue.copyIssue(issue: issue))
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
                Section("Status") {
                    Picker("Issue status", selection: $issueCopy.isOpen) {
                        Text("Open")
                            .tag(true)
                        Text("Closed")
                            .tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                Section("Tags") {
                    TagSelectionView(selection: $issueCopy.wrappedTags)
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
        .sheet(item: $errorWrapper) { error in
            ErrorView(errorWrapper: error)
        }
        .safeAreaInset(edge: .bottom) {
            ProminentButton("Save Changes") {
                Task {
                    do {
                        try await persistenceController.copyIssue(from: issueCopy, to: issue)
                    } catch {
                        errorWrapper = .init(error: error, message: "Failed to save issue changes.")
                    }
                }
            }
            .disabled(issueCopy.equals(issue))
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if !issueCopy.equals(issue) {
                        showingCancelDialog = true
                    } else {
                        editMode?.wrappedValue = .inactive
                    }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    Task {
                        do {
                            try await persistenceController.copyIssue(from: issueCopy, to: issue)
                            editMode?.wrappedValue = .inactive
                        } catch {
                            errorWrapper = .init(error: error, message: "Failed to save issue changes.")
                        }
                    }
                }
                .disabled(issueCopy.equals(issue))
            }
        }
        .confirmationDialog("Cancel changes", isPresented: $showingCancelDialog) {
            Button("Don't save", role: .destructive) {
                editMode?.wrappedValue = .inactive
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
                .environmentObject(PersistenceController.preview)
        }
    }
}
