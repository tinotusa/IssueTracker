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
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    var body: some View {
        NavigationStack {
            List {
                Group {
                    nameSection
                    descriptionSection
                    prioritySection
                    addTagsSection
                    selectedTagsSection
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
            }
            .listStyle(.plain)
            .navigationTitle("Add issue")
            .background(Color.customBackground)
            .sheet(item: $errorWrapper) { error in
                ErrorView(errorWrapper: error)
            }
            .toolbarBackground(Color.customBackground)
            .toolbar {
                toolbarItems
            }
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add Issue", action: addIssue)
                    .disabled(!issueProperties.allFieldsFilled)
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
        }
    }
    
    var descriptionSection: some View {
        Section("Description") {
            TextField("Issue description", text: $issueProperties.issueDescription, axis: .vertical)
                .lineLimit(4 ... 8)
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
    
    var addTagsSection: some View {
        Section("Add tags") {
            TagSelectionView(selection: $issueProperties.tags)
        }
    }
    
    var selectedTagsSection: some View {
        Section("Selected tags") {
            if issueProperties.tags.isEmpty {
                Text("No tags selected.")
                    .foregroundColor(.customSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            WrappingHStack {
                ForEach(Array(issueProperties.tags)) { tag in
                    Text(tag.wrappedName)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", action: dismiss.callAsFunction)
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Add Issue", action: addIssue)
                .disabled(!issueProperties.allFieldsFilled)
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
}

struct AddIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        AddIssueView(project: .preview)
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PersistenceController.preview)
    }
}
