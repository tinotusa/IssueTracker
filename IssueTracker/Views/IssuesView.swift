//
//  IssuesView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI
import CoreData

struct IssuesView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    private let project: Project
    
    @FetchRequest(sortDescriptors: [])
    private var issues: FetchedResults<Issue>

    @StateObject private var viewModel = IssuesViewModel()
    @State private var selectedIssue: Issue?
    
    init(project: Project) {
        self.project = project
        _issues = FetchRequest<Issue>(
            sortDescriptors: [.init(\.dateCreated_, order: .forward)],
            predicate: NSPredicate(format: "%K == %@", "project", project)
        )
    }
    
    var body: some View {
        // TODO: add swipe actions
        List {
            Group {
                if issues.isEmpty {
                    Text("No issues to see.\nTap the Add issue button below to start.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.customSecondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    ForEach(issues) { issue in
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
                }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.customBackground)
        }
        .listStyle(.plain)
        .background(Color.customBackground)
        .scrollContentBackground(.hidden)
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
                    Button("test") { print("hello") }
                    Button("test") { print("world") }
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
