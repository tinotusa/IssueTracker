//
//  FilteredIssuesListView.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import SwiftUI

struct FilteredIssuesListView: View {
    let closeAction: (Issue) -> Void
    let deleteAction: (Issue) -> Void
    
    @FetchRequest(sortDescriptors: [])
    private var issues: FetchedResults<Issue>
    
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var selectedIssue: Issue?
    
    init(
        selectedIssue: Binding<Issue?>,
        sortDescriptor: SortDescriptor<Issue>, predicate: NSPredicate,
        closeAction: @escaping (Issue) -> Void,
        deleteAction: @escaping (Issue) -> Void
    ) {
        _selectedIssue = selectedIssue
        self.closeAction = closeAction
        self.deleteAction = deleteAction
        _issues = FetchRequest(
            sortDescriptors: [sortDescriptor],
            predicate: predicate
        )
    }
    
    var body: some View {
        List {
            if issues.isEmpty {
                Text("No issues to see.\nTap the Add issue button below to start.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.customSecondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.customBackground)
            } else {
                ForEach(issues) { issue in
                    Button {
                        selectedIssue = issue
                    } label: {
                        IssueRowView(issue: issue)
                    }
                    .swipeActions {
                        Button {
                            closeAction(issue)
                        } label: {
                            Label("Close issue", systemImage: "checkmark.circle.fill")
                                .labelStyle(.iconOnly)
                        }
                        .tint(.green)
                        Button(role: .destructive) {
                            deleteAction(issue)
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
            }
        }
        .listStyle(.plain)
        .background(Color.customBackground)
        .scrollContentBackground(.hidden)
    }
}

struct FilteredIssuesListView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.issuesPreview.container.viewContext
    static var previews: some View {
        FilteredIssuesListView(
            selectedIssue: .constant(nil),
            sortDescriptor: .init(\.dateCreated_, order: .forward),
            predicate: .init(format: "(status_ == %@) AND (TRUEPREDICATE)", "open"),
            closeAction: { _ in },
            deleteAction: { _ in }
        )
        .environment(\.managedObjectContext, viewContext)
    }
}
