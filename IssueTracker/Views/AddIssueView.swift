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
    @State private var issueData = IssueData()
    
    @Environment(\.managedObjectContext) private var viewContext
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
            .persistenceErrorAlert(isPresented: $persistenceController.showingError, presenting: $persistenceController.persistenceError)
            .toolbarBackground(Color.customBackground)
            .toolbar {
                toolbarItems
            }
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add Issue") {
                    addIssue()
                }
                .disabled(!issueData.allFieldsFilled)
            }
        }
    }
}

// MARK: - List sections
private extension AddIssueView {
    var nameSection: some View{
        Section("Name") {
            TextField("Issue name", text: $issueData.name)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    var descriptionSection: some View {
        Section("Description") {
            TextField("Issue description", text: $issueData.description, axis: .vertical)
                .lineLimit(4 ... 8)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    var prioritySection: some View {
        Section("Priority") {
            Picker("Issue priority", selection: $issueData.priority) {
                ForEach(Issue.Priority.allCases) { priority in
                    Text(priority.title)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    var addTagsSection: some View {
        Section("Add tags") {
            TagSelectionView(selection: $issueData.tags)
        }
    }
    
    var selectedTagsSection: some View {
        Section("Selected tags") {
            if issueData.tags.isEmpty {
                Text("No tags selected.")
                    .foregroundColor(.customSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            WrappingHStack {
                ForEach(Array(issueData.tags)) { tag in
                    Text(tag.wrappedName)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Add Issue") {
                addIssue()
            }
            .disabled(!issueData.allFieldsFilled)
        }
    }
}

// MARK: - Functions
private extension AddIssueView {
    func addIssue() {
        let didSave = persistenceController.addIssue(
            name: issueData.name,
            issueDescription: issueData.description,
            priority: issueData.priority,
            tags: issueData.tags,
            project: project
        )
        if didSave {
            dismiss()
        }
    }
}

struct AddIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        AddIssueView(project: .example)
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PersistenceController.preview)
    }
}
