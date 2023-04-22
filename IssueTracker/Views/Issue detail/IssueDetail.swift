//
//  IssueDetail.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct IssueDetail: View {
    @ObservedObject private(set) var issue: Issue
    
    @Environment(\.editMode) private var editMode
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var persistenceController: PersistenceController
    
    var body: some View {
        if editMode?.wrappedValue == .active {
            EditIssueView(issue: issue)
        } else {
            IssueSummary(issue: issue)
                .toolbar {
                    toolbarItems
                }
                .navigationDestination(for: URL.self) { imageURL in
                    ImageDetailView(url: imageURL)
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
