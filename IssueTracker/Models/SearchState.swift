//
//  SearchState.swift
//  IssueTracker
//
//  Created by Tino on 23/4/2023.
//

import SwiftUI

struct SearchState {
    /// The search text for the searchable modifier.
    var searchText = ""
    /// The search scope for the search bar.
    var searchScope = SearchScopes.name
    /// The predicate used for the FilteredIssuesListView
    var predicate: NSPredicate = .init()
    
    /// The search scopes for the IssuesListView
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
}

extension SearchState {
    /// Sets the predicate based on the search text.
    mutating func runSearch(_ project: Project) {
        if searchText.isEmpty {
            predicate = NSPredicate(
                format: "(project == %@)", project)
            return
        }
        var format = "(project == %@)"
        switch searchScope {
        case .description:
            format += "AND (issueDescription CONTAINS[cd] %@)"
            predicate = NSPredicate(format: format,  project, searchText)
        case .name:
            format += "AND (name CONTAINS[cd] %@)"
            predicate = NSPredicate(format: format,  project, searchText)
        case .tag:
            format += "AND (ANY tags.name CONTAINS[cd] %@)"
            predicate = NSPredicate(format: format,  project, searchText)
        }
    }
}
