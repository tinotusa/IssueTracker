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
    @StateObject private var viewModel = AddIssueViewModel()
    let project: Project
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
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
                    LabeledInputField("Tags:") {
                        HStack {
                            CustomTextField("New tag", text: $viewModel.newTag)
                            PlainButton("Add tag") {
                                
                            }
                        }
                        .padding(.bottom)
                        LazyHGrid(rows: [.init(.adaptive(minimum: 100))]) {
                            ForEach(allTags) { tag in
                                TagButton(tag.name ?? "Not set") {
                                    viewModel.addTag(tag)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add Issue") {
                    
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
    static var viewContext = PersistenceController.shared.container.viewContext
    static var previews: some View {
        AddIssueView(project: .example(context: viewContext))
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
