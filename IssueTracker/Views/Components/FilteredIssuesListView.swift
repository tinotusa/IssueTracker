//
//  FilteredIssuesListView.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import SwiftUI

struct FilteredIssuesListView<Content: View>: View {
    let content: (Issue) -> Content
    
    @FetchRequest(sortDescriptors: [])
    private var issues: FetchedResults<Issue>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    init(
        sortDescriptor: SortDescriptor<Issue>,
        predicate: NSPredicate,
        @ViewBuilder content: @escaping (Issue) -> Content
    ) {
        self.content = content
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
                    content(issue)
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
            sortDescriptor: .init(\.dateCreated, order: .forward),
            predicate: .init(format: "(status == %@) AND (TRUEPREDICATE)", "open")
        ) { issue in
            Text(issue.wrappedName)
        }
        .environment(\.managedObjectContext, viewContext)
    }
}
