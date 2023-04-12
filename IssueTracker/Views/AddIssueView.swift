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
    @State private var name = ""
    @State private var description = ""
    @State private var priority: Issue.Priority = .low
    @State private var tags: Set<Tag> = []
    @State private var newTag = ""
    
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
            .toolbarBackground(Color.customBackground)
            .toolbar {
                toolbarItems
            }
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add Issue") {
                    persistenceController.addIssue(
                        name: name,
                        issueDescription: description,
                        priority: priority,
                        tags: tags,
                        project: project
                    )
                    dismiss()
                }
//                .disabled(!viewModel.allFieldsFilled)
            }
        }
    }
}

private extension AddIssueView {
    var nameSection: some View{
        Section("Name") {
            TextField("Issue name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    var descriptionSection: some View {
        Section("Description") {
            TextField("Issue description", text: $description, axis: .vertical)
                .lineLimit(4 ... 8)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    var prioritySection: some View {
        Section("Priority") {
            Picker("Issue priority", selection: $priority) {
                ForEach(Issue.Priority.allCases) { priority in
                    Text(priority.title)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    var addTagsSection: some View {
        Section("Add tags") {
            TagSelectionView(selection: $tags)
        }
    }
    
    var selectedTagsSection: some View {
        Section("Selected tags") {
            if tags.isEmpty {
                Text("No tags selected.")
                    .foregroundColor(.customSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            WrappingHStack {
                ForEach(Array(tags)) { tag in
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
                persistenceController.addIssue(
                    name: name,
                    issueDescription: description,
                    priority: priority,
                    tags: tags,
                    project: project
                )
                dismiss()
            }
        }
    }
    
}

struct AddIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        AddIssueView(project: .init(name: "test", startDate: .now, context: viewContext))
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PersistenceController())
    }
}
