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
            ScrollView {
                VStack(alignment: .leading) {
                    LabeledInputField("Name:") {
                        CustomTextField("Issue name", text: $viewModel.name)
                    }
                    LabeledInputField("Description:") {
                        CustomTextField("Issue description", text: $viewModel.description)
                            .lineLimit(4 ... 8)
                    }
                    LabeledInputField("Priority:") {
                        Picker("Issue priority", selection: $viewModel.priority) {
                            ForEach(Issue.Priority.allCases) { priority in
                                Text(priority.title)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    LabeledInputField("Add tags:") {
                        TagSelectionView(selectedTags: $viewModel.tags)
                    }
                    LabeledInputField("Selected tags:") {
                        if viewModel.tags.isEmpty {
                            Text("No tags selected.")
                                .foregroundColor(.customSecondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        // TODO: add custom layout here
                        LazyHGrid(rows: [.init(.adaptive(minimum: 100))]) {
                            ForEach(Array(viewModel.tags)) { tag in
                                Text(tag.wrappedName)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .bodyStyle()
            .navigationTitle("Add issue")
            .background(Color.customBackground)
            .toolbarBackground(Color.customBackground)
            .toolbar {
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
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add Issue") {
                    viewModel.addIssue()
                    dismiss()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(!viewModel.allFieldsFilled)
            }
        }
    }
}

struct AddIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.tagsPreview.container.viewContext
    
    static var previews: some View {
        AddIssueView(project: .init(name: "test", startDate: .now, context: viewContext))
            .environment(\.managedObjectContext, viewContext)
    }
}
