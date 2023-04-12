//
//  AddProjectViewModel.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import os
import SwiftUI
import CoreData

///// View model for AddProjectView.
//final class AddProjectViewModel: ObservableObject {
//    /// The name of the project.
//    private lazy var persistenceController = PersistenceController.shared
//    
//    /// Creates a new view model.
//    /// - Parameter context: The context for saving objects.
//    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
//        self.viewContext = context
//    }
//    
//    private let logger = Logger(
//        subsystem: Bundle.main.bundleIdentifier!,
//        category: String(describing: AddProjectViewModel.self)
//    )
//}
//
//extension AddProjectViewModel {
//    /// Filters the given name by removing non alphanumerics and non spaces.
//    /// - Parameter name: The name to filter.
//    func filterName(_ name: String) {
//        let filteredName = Project.filterName(name)
//        if filteredName != projectName {
//            projectName = filteredName
//        }
//    }
//}
