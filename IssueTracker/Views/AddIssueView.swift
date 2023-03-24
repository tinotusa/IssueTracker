//
//  AddIssueView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI
import CoreData

struct AddIssueView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddIssueViewModel
    @ObservedObject var project: Project
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    init(project: Project) {
        self.project = project
        _viewModel = StateObject(wrappedValue: AddIssueViewModel(project: project))
    }
    
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
                    viewModel.addIssue()
                    dismiss()
                }
                .disabled(!viewModel.allFieldsFilled)
            }
        }
    }
}

private extension AddIssueView {
    var nameSection: some View{
        Section("Name") {
            TextField("Issue name", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    var descriptionSection: some View {
        Section("Description") {
            TextField("Issue description", text: $viewModel.description, axis: .vertical)
                .lineLimit(4 ... 8)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    var prioritySection: some View {
        Section("Priority") {
            Picker("Issue priority", selection: $viewModel.priority) {
                ForEach(Issue.Priority.allCases) { priority in
                    Text(priority.title)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    var addTagsSection: some View {
        Section("Add tags") {
            TagSelectionView(selection: $viewModel.tags)
        }
    }
    
    var selectedTagsSection: some View {
        Section("Selected tags") {
            if viewModel.tags.isEmpty {
                Text("No tags selected.")
                    .foregroundColor(.customSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            WrappingHStack {
                ForEach(Array(viewModel.tags)) { tag in
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
                viewModel.addIssue()
                dismiss()
            }
            .disabled(!viewModel.allFieldsFilled)
        }
    }
    
}

struct AddIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        AddIssueView(project: .init(name: "test", startDate: .now, context: viewContext))
            .environment(\.managedObjectContext, viewContext)
    }
}
