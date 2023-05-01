//
//  EditIssueView.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import SwiftUI

struct EditIssueView: View {
    @Binding var issueProperties: IssueProperties
    @State private var errorWrapper: ErrorWrapper?
    
    @Environment(\.editMode) private var editMode
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var persistenceController: PersistenceController
    
    
    var body: some View {
        List {
            Group {
                nameSection
                descriptionSection
                prioritySection
                tagsSection
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
            ProminentButton("Done", action: cancel)
        }
        .toolbar {
            toolbarItems
        }
    }
}

// MARK: - Views {
private extension EditIssueView {
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", action: cancel)
        }
    }
}

// MARK: - List sections
private extension EditIssueView {
    var nameSection: some View {
        Section("Issue name") {
            CustomTextField("Issue name", text: $issueProperties.name)
        }
    }
    
    var descriptionSection: some View {
        Section("Description") {
            TextField("Issue Description", text: $issueProperties.issueDescription, axis: .vertical)
                .lineLimit(3...)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    var prioritySection: some View {
        Section("Priority") {
            Picker("Issue priority", selection: $issueProperties.priority) {
                ForEach(Issue.Priority.allCases) { priority in
                    Text(priority.title)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    var tagsSection: some View {
        Section("Tags") {
            TagSelectionView(selection: $issueProperties.tags)
        }
    }
}

// MARK: - Functions
private extension EditIssueView {
    func cancel() {
        editMode?.wrappedValue = .inactive
    }
}

struct IssueEditView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditIssueView(issueProperties: .constant(.default))
        }
    }
}
