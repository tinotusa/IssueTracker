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
        VStack(alignment: .leading) {
            header
                .padding([.horizontal, .top])
            // TODO: add swipe actions
            ScrollView {
                VStack(alignment: .leading) {
                    if issues.isEmpty {
                        Text("No issues to see.\nTap the Add issue button below to start.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.customSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(issues) { issue in
                            Button {
                                selectedIssue = issue
                            } label: {
                                IssueRowView(issue: issue)
                                    .padding(.bottom)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add Issue") {
                    viewModel.showingAddIssueView = true
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .bodyStyle()
        .background(Color.customBackground)
        .sheet(isPresented: $viewModel.showingAddIssueView) {
            AddIssueView(project: project)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(item: $selectedIssue) { selectedIssue in
            IssueDetail(issue: selectedIssue)
        }
    }
}

private extension IssuesView {
    var header: some View {
        HStack {
            Text("Issues")
                .titleStyle()
            Spacer()
            Menu {
                Button("test") { }
            } label: {
                Text("Sort")
                    .foregroundColor(.buttonLabel)
            }
            Menu {
                Button("test") { }
            } label: {
                Text("Filter")
                    .foregroundColor(.buttonLabel)
            }
        }
    }
}

struct IssuesView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.issuesPreview.container.viewContext
    static var previews: some View {
        IssuesView(project: .example(context: viewContext))
            .environment(
                \.managedObjectContext,
                 viewContext
            )
    }
}
