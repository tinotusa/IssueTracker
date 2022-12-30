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
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated_, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    init(project: Project) {
        self.project = project
        _viewModel = StateObject(wrappedValue: AddIssueViewModel(project: project))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            header
                .padding(.horizontal)
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Add Issue")
                        .titleStyle()
                    LabeledInputField("Issue name:") {
                        CustomTextField("Issue name", text: $viewModel.name)
                    }
                    // TODO: description needs to be a bigger text box
                    LabeledInputField("Description:") {
                        CustomTextField("Issue description", text: $viewModel.description)
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
                        CustomTextField("Search tag", text: $viewModel.newTag)
                        TagFilterView(filterText: viewModel.newTag) { tag in
                            viewModel.addTag(tag)
                        }
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
                                Text(tag.name)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add Issue") {
                    viewModel.addIssue()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(!viewModel.allFieldsFilled)
            }
        }
        .bodyStyle()
        .background(Color.customBackground)
    }
}

private extension AddIssueView {
    var header: some View {
        HStack {
            PlainButton("Close") {
                dismiss()
            }
            Spacer()
            PlainButton("Add issue") {
                
            }
            .disabled(!viewModel.allFieldsFilled)
        }
    }
}

struct AddIssueView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.tagsPreview.container.viewContext
    static var previews: some View {
        AddIssueView(project: .example(context: viewContext))
            .environment(\.managedObjectContext, viewContext)
    }
}
