//
//  IssueDetail.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct IssueDetail: View {
    @ObservedObject private(set) var issue: Issue
    @State private var draftIssueProperties = IssueProperties.default
    @State private var errorWrapper: ErrorWrapper?
    @State private var refreshID = UUID()
    
    @Environment(\.editMode) private var editMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var persistenceController: PersistenceController
    
    var body: some View {
        Group {
            if editMode?.wrappedValue == .active {
                EditIssueView(issueProperties: $draftIssueProperties)
                    .onAppear(perform: setDraftIssue)
                    .onDisappear(perform: saveEdits)
                    .sheet(item: $errorWrapper) { error in
                        ErrorView(errorWrapper: error)
                            .sheetWithIndicator()
                    }
            } else {
                IssueSummary(issue: issue)
                    .toolbar {
                        toolbarItems
                    }
                    .navigationDestination(for: URL.self) { imageURL in
                        ImageDetailView(url: imageURL)
                    }
                    .id(refreshID)
            }
        }
        .toolbar {
            if editMode?.wrappedValue == .active {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: cancel)
                }
            }
        }
    }
}

// MARK: - Views
private extension IssueDetail {
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            EditButton()
        }
    }
}

// MARK: - Functions
private extension IssueDetail {
    func setDraftIssue() {
        draftIssueProperties = issue.issueProperties
    }
    
    func cancel() {
        draftIssueProperties = issue.issueProperties
        editMode?.wrappedValue = .inactive
    }
    
    func saveEdits() {
        if draftIssueProperties == issue.issueProperties {
            return
        }
        Task {
            do {
                try await persistenceController.updateIssue(issue, with: draftIssueProperties)
                refreshID = UUID()
            } catch {
                errorWrapper = .init(error: error, message: "Failed to save issue edits.")
            }
        }
    }
    
}
struct IssueDetail_Previews: PreviewProvider {
    static let viewContext = PersistenceController.preview.container.viewContext
    static var previews: some View {
        NavigationStack {
            IssueDetail(issue: .example)
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(PersistenceController.preview)
        }
    }
}
