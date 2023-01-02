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
    
    @StateObject private var viewModel: IssuesViewModel
    @State private var sortDescriptor = SortDescriptor<Issue>(\.dateCreated_, order: .forward)
   
    
    init(project: Project) {
        self.project = project
        let predicate = NSPredicate(format: "(project == %@) AND (status_ == %@)",  project, "open")
        _viewModel = StateObject(wrappedValue: IssuesViewModel(project: project, predicate: predicate))
    }
    
    var body: some View {
        FilteredIssuesListView(
            sortDescriptor: sortDescriptor,
            predicate: viewModel.predicate
        ) { issue in
            Button {
                viewModel.selectedIssue = issue
            } label: {
                IssueRowView(issue: issue)
            }
            .swipeActions {
                Button {
                    viewModel.closeIssue(issue)
                } label: {
                    Label("Close issue", systemImage: "checkmark.circle.fill")
                }
                .tint(.green)
                Button(role: .destructive) {
                    viewModel.deleteIssue(issue)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .searchScopes($viewModel.searchScope) {
            ForEach(IssuesViewModel.SearchScopes.allCases) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .onChange(of: viewModel.searchText) { _ in viewModel.runSearch() }
        .onChange(of: viewModel.searchScope) { _ in viewModel.runSearch() }
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
        .sheet(item: $viewModel.selectedIssue) { selectedIssue in
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
