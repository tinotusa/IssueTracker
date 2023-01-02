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
    /// The search text for the searchable modifier.
    @Published var searchText = ""
    /// The search scope for the search bar.
    @Published var searchScope = SearchScopes.name
    /// The currently selected issue.
    @Published var selectedIssue: Issue?
    /// The predicate used for the FilteredIssuesListView
    @Published var predicate: NSPredicate
    /// The sorting type for the issues (e.g sort type title)
    @Published var sortType = SortType.date
    /// The sort order for the sort type.
    @Published var sortOrder = SortOrder.forward
    /// The sort descriptor for the issues.
    @Published var sortDescriptor = SortDescriptor<Issue>(\.dateCreated_, order: .forward)
    
    /// The current project the issues belong to.
    private let project: Project
    /// The view context.
    private let viewContext: NSManagedObjectContext
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "IssuesViewModel")
    
    /// Creates a new IssuesViewModel
    /// - Parameters:
    ///   - project: The project the issues being listed belong to.
    ///   - predicate: The predicate used for filtering and searching.
    ///   - viewContext: The view context to save to.
    init(project: Project,
         predicate: NSPredicate,
         viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    ) {
        self.project = project
        self.predicate = predicate
        self.viewContext = viewContext
    }
}
// MARK: - Enums
extension IssuesViewModel {
    /// The search scopes for the IssuesView
    enum SearchScopes: CaseIterable, Identifiable {
        case name
        case description
        
        /// A unique id for the scope.
        var id: Self { self }
        
        /// The title of the search scope.
        var title: LocalizedStringKey {
            switch self {
            case .description: return "Description"
            case .name: return "Name"
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
    /// Closes the given issue.
    /// - Parameter issue: The `Issue` to close.
    func closeIssue(_ issue: Issue) {
        log.debug("Closing issue \"\(issue.name)\" ...")
        issue.status = .closed
        do {
            try withAnimation {
                try viewContext.save()
            }
            log.debug("Successfully close issue.")
        } catch {
            viewContext.rollback()
            log.error("Failed to close issue. \(error)")
        }
    }
    /// Deletes the given issue from core data.
    /// - Parameter issue: The `Issue` to delete.
    func deleteIssue(_ issue: Issue) {
        log.debug("Deleting issue with name \"\(issue.name)\" ...")
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
                format: "(project == %@) AND (status_ == %@)", project, "open")
            return
        }
        var format = "(project == %@) AND (status_ == %@)"
        switch searchScope {
        case .description:
            format += "AND (issueDescription_ CONTAINS[cd] %@)"
            predicate = NSPredicate(format: format,  project, "open", searchText)
        case .name:
            format += "AND (name_ CONTAINS[cd] %@)"
            predicate = NSPredicate(format: format,  project, "open", searchText)
        }
    }
    
    /// Sets the sort descriptor's order.
    /// - Parameter sortOrder: The order to set
    func setSortOrder(to sortOrder: SortOrder) {
        self.sortOrder = sortOrder
        log.debug("Settings sort ...")
        switch sortType {
        case .date:
            sortDescriptor = .init(\.dateCreated_, order: sortOrder)
            log.debug("sort set to date with sortOrder: \(sortOrder)")
        case .title:
            sortDescriptor = .init(\.name_, order: sortOrder)
            log.debug("sort set to title with sortOrder: \(sortOrder)")
        case .priority:
            sortDescriptor = .init(\.priority_, order: sortOrder)
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
