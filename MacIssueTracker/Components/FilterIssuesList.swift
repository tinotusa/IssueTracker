//
//  FilterIssuesList.swift
//  MacIssueTracker
//
//  Created by Tino on 26/1/2023.
//

import SwiftUI

struct FilterIssuesList<Content: View>: View {
    let content: (Issue) -> Content
    @Binding var selectedIssue: Issue?
    
    @FetchRequest(sortDescriptors: [])
    private var issues: FetchedResults<Issue>
    
    init(
        selection selectedIssue: Binding<Issue?>,
        predicate: NSPredicate,
        @ViewBuilder content: @escaping (Issue) -> Content
    ) {
        _selectedIssue = selectedIssue
        self.content = content
        _issues = FetchRequest(
            sortDescriptors: [.init(\.dateCreated_, order: .forward)],
            predicate: predicate
        )
    }
    
    var body: some View {
        List(selection: $selectedIssue) {
            Text("Issues")
                .foregroundColor(.secondary)
            if issues.isEmpty {
                Text("No issues found.")
            } else {
                ForEach(issues) { issue in
                    content(issue)
                }
            }
        }
    }
}

struct FilterIssuesList_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    static var project = Project.example(context: viewContext)
    static var predicate = NSPredicate(format: "project == %@ && status_ == %@", project, "open")
    
    static var previews: some View {
        FilterIssuesList(selection: .constant(nil), predicate: predicate) { issue in
            IssueRow(issue: issue)
        }
        .environment(\.managedObjectContext, viewContext)
    }
}
