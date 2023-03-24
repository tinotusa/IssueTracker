//
//  IssuesViewModel.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import Foundation
import CoreData
import os
import SwiftUI

final class IssuesViewModel: ObservableObject {
    /// A boolean indicating whether or not the AddIssueView is showing.
    @Published var showingAddIssueView = false
    @Published var showingEditTagsView = false
    /// The search text for the searchable modifier.
    @Published var searchText = ""
    /// The search scope for the search bar.
    @Published var searchScope = SearchScopes.name
    /// The issue status being listed.
    @Published var searchIssueStatus = Issue.Status.open
    /// The currently selected issue.
    @Published var selectedIssue: Issue?
    /// The predicate used for the FilteredIssuesListView
    @Published var predicate: NSPredicate
    /// The sorting type for the issues (e.g sort type title)
    @Published var sortType = SortType.date
    /// The sort order for the sort type.
    @Published var sortOrder = SortOrder.forward
    /// The sort descriptor for the issues.
    @Published var sortDescriptor = SortDescriptor<Issue>(\.dateCreated, order: .forward)
    
    /// The current project the issues belong to.
    let project: Project
    /// The view context.
    private let viewContext: NSManagedObjectContext
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "IssuesViewModel")
    
    /// Creates a new IssuesViewModel
    /// - Parameters:
    ///   - project: The project the issues being listed belong to.
    ///   - viewContext: The view context to save to.
    init(project: Project,
         viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) {
        self.project = project
        self.predicate = NSPredicate(format: "(project == %@) AND (status == %@)",  project, "open")
        self.viewContext = viewContext
    }
}
// MARK: - Enums
extension IssuesViewModel {
    /// The search scopes for the IssuesView
    enum SearchScopes: CaseIterable, Identifiable {
        case name
        case description
        case tag
        
        /// A unique id for the scope.
        var id: Self { self }
        
        /// The title of the search scope.
        var title: LocalizedStringKey {
            switch self {
            case .description: return "Description"
            case .name: return "Name"
            case .tag: return "Tag"
            }
        }
    }
    
    /// The things that can be used for sorting.
    enum SortType: CaseIterable, Identifiable {
        case title
        case date
        case priority
        
        /// A unique id for the type.
        var id: Self { self }
        
        /// The title for a case.
        var title: LocalizedStringKey {
            switch self {
            case .date: return "Date (Default)"
            case .priority: return "Priority"
            case .title: return "Title"
            }
        }
    }
}

// MARK: - Functions
extension IssuesViewModel {
    /// Toggles the given issue's status.
    /// - Parameter issue: The issue to toggle.
    func toggleStatus(_ issue: Issue) {
        switch issue.wrappedStatus {
        case .open: issue.wrappedStatus = .closed
        case .closed: issue.wrappedStatus = .open
        }
        do {
            try viewContext.save()
            log.debug("Successfully toggled issue status to \(issue.wrappedStatus.rawValue).")
        } catch {
            log.error("Failed to save view context. \(error)")
        }
    }
    
    /// Sets the given issue to the given status.
    /// - Parameter issue: The issue to modify.
    /// - Parameter status: The status to set the issue to.
    func setIssueStatus(_ issue: Issue, to status: Issue.Status) {
        log.debug(#"Setting issue "\#(issue.wrappedName)" to \#(status.rawValue)"#)
        if issue.wrappedStatus == status {
            log.debug("Issue is already \(status.rawValue).")
            return
        }
        issue.wrappedStatus = status
        do {
            try withAnimation {
                try viewContext.save()
            }
            log.debug(#"Successfully set the issue "\#(issue.wrappedName)" status to \#(status.rawValue)."#)
        } catch {
            viewContext.rollback()
            log.debug(#"Failed to set the issue "\#(issue.wrappedName)" status to \#(status.rawValue)."#)
        }
    }
    
    /// Deletes the given issue from core data.
    /// - Parameter issue: The `Issue` to delete.
    func deleteIssue(_ issue: Issue) {
        log.debug("Deleting issue with name \"\(issue.wrappedName)\" ...")
        // TODO: either set it to some archived state or implement undo ?
        viewContext.delete(issue)
        do {
            try withAnimation {
                try viewContext.save()
            }
            log.debug("Successfully deleted issue.")
        } catch {
            viewContext.rollback()
            log.error("Failed to delete issue. \(error)")
        }
    }
    
    /// Sets the predicate based on the search text.
    func runSearch() {
        if searchText.isEmpty {
            predicate = NSPredicate(
                format: "(project == %@) AND (status == %@)", project, searchIssueStatus.rawValue)
            return
        }
        var format = "(project == %@) AND (status == %@)"
        switch searchScope {
        case .description:
            format += "AND (issueDescription CONTAINS[cd] %@)"
            predicate = NSPredicate(format: format,  project, searchIssueStatus.rawValue, searchText)
        case .name:
            format += "AND (name CONTAINS[cd] %@)"
            predicate = NSPredicate(format: format,  project, searchIssueStatus.rawValue, searchText)
        case .tag:
            format += "AND (ANY tags.name CONTAINS[cd] %@)"
            predicate = NSPredicate(format: format,  project, searchIssueStatus.rawValue, searchText)
        }
    }
    
    /// Sets the sort descriptor's order.
    /// - Parameter sortOrder: The order to set
    func setSortOrder(to sortOrder: SortOrder) {
        self.sortOrder = sortOrder
        log.debug("Settings sort ...")
        switch sortType {
        case .date:
            sortDescriptor = .init(\.dateCreated, order: sortOrder)
            log.debug("sort set to date with sortOrder: \(sortOrder)")
        case .title:
            sortDescriptor = .init(\.name, order: sortOrder)
            log.debug("sort set to title with sortOrder: \(sortOrder)")
        case .priority:
            sortDescriptor = .init(\.priority, order: sortOrder)
            log.debug("sort set to priority with sortOrder: \(sortOrder)")
        }
    }
}

extension SortOrder: CustomStringConvertible {
    public var description: String {
        switch self {
        case .reverse: return "Reverse"
        case .forward: return "Forward"
        }
    }
}
