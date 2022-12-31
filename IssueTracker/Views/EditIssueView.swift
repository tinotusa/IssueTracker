//
//  EditIssueView.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import SwiftUI

struct EditIssueView: View {
    @ObservedObject var issue: Issue
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: EditIssueViewModel
    @State private var showingCancelDialog = false
    
    init(issue: Issue) {
        self.issue = issue
        _viewModel = StateObject(wrappedValue: EditIssueViewModel(issue: issue))
    }
    
    var body: some View {
        VStack {
            header
                .padding([.horizontal, .top])
            
            ScrollView {
                VStack(alignment: .leading) {
                    LabeledInputField("Issue name:") {
                        CustomTextField("Issue name", text: $viewModel.issueCopy.name)
                    }
                    LabeledInputField("Description:") {
                        CustomTextField("Issue Description", text: $viewModel.issueCopy.issueDescription)
                    }
                    LabeledInputField("Priority:") {
                        Picker("Issue priority", selection: $viewModel.issueCopy.priority) {
                            ForEach(Issue.Priority.allCases) { priority in
                                Text(priority.title)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    LabeledInputField("Tags:") {
                        TagFilterView(selectedTags: $viewModel.selectedTags)
                    }
                }
                .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Save Changes") {
                    viewModel.saveChanges()
                }
                .disabled(!viewModel.hasChanges)
            }
        }
        .navigationBarBackButtonHidden(true)
        .confirmationDialog("Cancel changes", isPresented: $showingCancelDialog) {
            Button("Don't save", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You haven't saved these changes.")
        }
    }
}
private extension EditIssueView {
    var header: some View {
        HStack {
            Button("Cancel") {
                if viewModel.hasChanges {
                    showingCancelDialog = true
                } else {
                    dismiss()
                }
            }
            Spacer()
            Button("Save") {
                viewModel.saveChanges()
            }
            .disabled(!viewModel.hasChanges)
        }
    }
}
struct IssueEditView_Previews: PreviewProvider {
    static let viewContext = PersistenceController.issuesPreview.container.viewContext
    static var previews: some View {
        EditIssueView(issue: Issue(name: "Test issue", issueDescription: "", priority: .low, tags: [], context: viewContext))
    }
}
