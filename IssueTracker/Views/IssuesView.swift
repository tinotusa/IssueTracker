//
//  IssuesView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI
import CoreData

struct IssuesView: View {
    private let project: Project
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = IssuesViewModel()
    @State private var selectedIssue: Issue?
    @State private var sortDescriptor = SortDescriptor<Issue>(\.dateCreated_, order: .forward)
    @State private var predicate: NSPredicate
    
    init(project: Project) {
        self.project = project
        _predicate = State(wrappedValue: NSPredicate(format: "(project == %@) AND (status_ == %@)",  project, "open"))
    }
    
    var body: some View {
        FilteredIssuesListView(
            sortDescriptor: sortDescriptor,
            predicate: predicate
        ) { issue in
            Button {
                selectedIssue = issue
            } label: {
                IssueRowView(issue: issue)
            }
            .swipeActions {
                Button {
                    viewModel.closeIssue(issue)
                } label: {
                    Label("Close issue", systemImage: "checkmark.circle.fill")
                        .labelStyle(.iconOnly)
                }
                .tint(.green)
                Button(role: .destructive) {
                    viewModel.deleteIssue(issue)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            ProminentButton("Add Issue") {
                viewModel.showingAddIssueView = true
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationBarTitle("Issues")
        .toolbarBackground(Color.customBackground, for: .navigationBar)
        .bodyStyle()
        .background(Color.customBackground)
        .sheet(isPresented: $viewModel.showingAddIssueView) {
            AddIssueView(project: project)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(item: $selectedIssue) { selectedIssue in
            IssueDetail(issue: selectedIssue)
        }
        .toolbar {
            ToolbarItemGroup (placement: .primaryAction) {
                Menu {
                    Menu("Title") {
                        Button {
                            sortDescriptor = .init(\.name_, order: .forward)
                        } label: {
                            Label("Ascending", systemImage: "chevron.up")
                        }
                        Button {
                            sortDescriptor = .init(\.name_, order: .reverse)
                        } label: {
                            Label("Descending", systemImage: "chevron.down")
                        }
                    }
                    Menu("Date") {
                        Button {
                            sortDescriptor = .init(\.dateCreated_, order: .forward)
                        } label: {
                            Label("Ascending", systemImage: "chevron.up")
                        }
                        Button {
                            sortDescriptor = .init(\.dateCreated_, order: .reverse)
                        } label: {
                            Label("Descending", systemImage: "chevron.down")
                        }
                    }
                    Menu("Priority") {
                        Button {
                            sortDescriptor = .init(\.priority_, order: .reverse)
                        } label: {
                            Label("Highest to lowest", systemImage: "chevron.up")
                        }
                        Button {
                            sortDescriptor = .init(\.priority_, order: .forward)
                        } label: {
                            Label("Lowest to  highest", systemImage: "chevron.down")
                        }
                    }
                } label: {
                    Text("Sort")
                }
                
                Menu {
                    Button("test") { }
                } label: {
                    Text("Filter")
                }
            }
        }
    }
}

struct IssuesView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.issuesPreview.container.viewContext
    
    static var previews: some View {
        NavigationStack {
            IssuesView(project: .example(context: viewContext))
                .environment(
                    \.managedObjectContext,
                     viewContext
            )
        }
    }
}
