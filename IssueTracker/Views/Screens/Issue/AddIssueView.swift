//
//  AddIssueView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI
import CoreData

struct AddIssueView: View {
    @ObservedObject var project: Project
    @State private var issueProperties = IssueProperties()
    @State private var errorWrapper: ErrorWrapper?
    @State private var showingTagsSheet = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Group {
                    nameSection
                    descriptionSection
                    prioritySection
                    AddTagsButton(
                        action: showTagsSheet,
                        tagCount: issueProperties.tags.count
                    )
                    .accessibilityIdentifier("addTagsButton")
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
            }
            .accessibilityIdentifier("issueForm")
            .listStyle(.plain)
            .navigationTitle("Add issue")
            .background(Color.customBackground)
            .sheet(item: $errorWrapper) { error in
                ErrorView(errorWrapper: error)
                    .sheetWithIndicator()
            }
            .sheet(isPresented: $showingTagsSheet) {
                TagSelectionView(selection: $issueProperties.tags)
            }
            .toolbarBackground(Color.customBackground)
            .toolbar {
                toolbarItems
            }
        }
    }
}

// MARK: - List sections
private extension AddIssueView {
    var nameSection: some View{
        Section("Name") {
            CustomTextField("Issue name", text: $issueProperties.name)
                .isMandatoryFormField(true)
                .accessibilityIdentifier("nameField")
        }
    }
    
    var descriptionSection: some View {
        Section("Description") {
            TextField("Issue description", text: $issueProperties.issueDescription, axis: .vertical)
                .lineLimit(4 ... 8)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("descriptionField")
        }
    }
    
    var prioritySection: some View {
        Section("Priority") {
            Picker("Issue priority", selection: $issueProperties.priority) {
                ForEach(Issue.Priority.allCases) { priority in
                    Text(priority.title)
                        .accessibilityIdentifier(priority.identifier)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("priorityPicker")
        }
    }
    
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", action: dismiss.callAsFunction)
                .accessibilityIdentifier("cancelButton")
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Add", action: addIssue)
                .disabled(!issueProperties.allFieldsFilled)
                .accessibilityIdentifier("AddIssueView-addIssueButton")
        }
    }
}

// MARK: - Functions
private extension AddIssueView {
    func addIssue() {
        Task {
            do {
                try await persistenceController.addIssue(issueProperties, project: project)
                dismiss()
            } catch {
                errorWrapper = ErrorWrapper(error: error, message: "Failed to add issue.")
            }
        }
    }
    
    func showTagsSheet() {
        showingTagsSheet = true
    }
}

struct AddIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        AddIssueView(project: .preview)
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PersistenceController.preview)
    }
}
