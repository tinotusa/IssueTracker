//
//  IssueEditView.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import SwiftUI

struct IssueEditView: View {
    @ObservedObject var issue: Issue
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: IssueEditViewModel
    @State private var showingCancelDialog = false
    
    init(issue: Issue) {
        self.issue = issue
        _viewModel = StateObject(wrappedValue: IssueEditViewModel(issue: issue))
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
        }
        .confirmationDialog("Cancel changes", isPresented: $showingCancelDialog) {
            Button("Don't save", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You haven't saved these changes.")
        }
    }
}
private extension IssueEditView {
    var header: some View {
        HStack {
            Button("Cancel") {
                showingCancelDialog = true
            }
            Spacer()
            Button("Save") {
                
            }
        }
    }
}
struct IssueEditView_Previews: PreviewProvider {
    static let viewContext = PersistenceController.issuesPreview.container.viewContext
    static var previews: some View {
        IssueEditView(issue: Issue(name: "Test issue", issueDescription: "", priority: .low, tags: [], context: viewContext))
    }
}
