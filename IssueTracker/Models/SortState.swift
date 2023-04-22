//
//  SortState.swift
//  IssueTracker
//
//  Created by Tino on 23/4/2023.
//

import SwiftUI

struct SortState {
    /// The sorting type for the issues (e.g sort type title)
    var sortType = SortType.date
    /// The sort order for the sort type.
    var sortOrder = SortOrder.forward
    /// The sort descriptor for the issues.
    var sortDescriptor = SortDescriptor<Issue>(\.dateCreated, order: .forward)
    
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

extension SortState {
    /// Sets the sort descriptor's order.
    /// - Parameter sortOrder: The order to set
    mutating func setSortOrder(to sortOrder: SortOrder) {
        self.sortOrder = sortOrder
        switch sortType {
        case .date:
            sortDescriptor = .init(\.dateCreated, order: sortOrder)
        case .title:
            sortDescriptor = .init(\.name, order: sortOrder)
        case .priority:
            sortDescriptor = .init(\.priority, order: sortOrder)
        }
    }
}
