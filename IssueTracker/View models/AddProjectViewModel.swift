//
//  AddProjectViewModel.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import os
import SwiftUI
import CoreData

/// View model for AddProjectView.
final class AddProjectViewModel: ObservableObject {
    /// The view context for core data.
    private let viewContext: NSManagedObjectContext
    /// The name of the project.
    @Published var projectName = ""
    private lazy var persistenceController = PersistenceController.shared
    
    /// Creates a new view model.
    /// - Parameter context: The context for saving objects.
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AddProjectViewModel.self)
    )
}

extension AddProjectViewModel {
    /// A boolean indication whether or not the add button is disabled.
    var addButtonDisabled: Bool {
        let name = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty
    }
    
    /// Adds a new Project to CoreData.
    func addProject() {
        logger.log("Adding a project")
        guard !addButtonDisabled else {
            logger.log("Failed to add project, the add button is disabled.")
            return
        }
        do {
            try persistenceController.addProject(name: projectName, dateStarted: .now)
        } catch {
            logger.error("Failed to add project. \(error)")
        }
    }
    
    /// Filters the given name by removing non alphanumerics and non spaces.
    /// - Parameter name: The name to filter.
    func filterName(_ name: String) {
        let filteredName = Project.filterName(name)
        if filteredName != projectName {
            projectName = filteredName
        }
    }
}
