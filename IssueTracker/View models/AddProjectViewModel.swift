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
    
    /// Creates a new view model.
    /// - Parameter context: The context for saving objects.
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }
    
    private let log = Logger(
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
        log.log("Adding a project")
        guard !addButtonDisabled else {
            log.log("Failed to add project, the add button is disabled.")
            return
        }
        let _ = Project(name: projectName, startDate: .now, context: viewContext)
        
        do {
            try viewContext.save()
            log.log("Successfully saved Project to view context's store.")
        } catch {
            log.error("Failed to save Project to view context's store.")
        }
        return
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
