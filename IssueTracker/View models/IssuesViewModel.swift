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
    /// The search text for the searchable modifier.
    @Published var searchText = ""
    /// The search scope for the search bar.
    @Published var searchScope = SearchScopes.name
    /// The issue status being listed.
    @Published var searchIssueStatus = Issue.Status.open
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
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: IssuesViewModel.self)
    )
    
    private lazy var persistenceController = PersistenceController.shared
    /// Creates a new IssuesViewModel
    /// - Parameters:
    ///   - project: The project the issues being listed belong to.
    ///   - viewContext: The view context to save to.
    init(project: Project) {
        self.project = project
        self.predicate = NSPredicate(format: "(project == %@) AND (status == %@)",  project, "open")
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
        logger.debug("Settings sort ...")
        switch sortType {
        case .date:
            sortDescriptor = .init(\.dateCreated, order: sortOrder)
            logger.debug("sort set to date with sortOrder: \(sortOrder)")
        case .title:
            sortDescriptor = .init(\.name, order: sortOrder)
            logger.debug("sort set to title with sortOrder: \(sortOrder)")
        case .priority:
            sortDescriptor = .init(\.priority, order: sortOrder)
            logger.debug("sort set to priority with sortOrder: \(sortOrder)")
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
