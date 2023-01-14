//
//  AddProjectViewModel.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import os
import SwiftUI
import CoreData

final class AddProjectViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    @Published var projectName = ""
    @Published var startDate = Date()

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
    }
    
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "AddProjectViewModel")
}

extension AddProjectViewModel {
    /// A boolean indication whether or not the add button is disabled.
    var addButtonDisabled: Bool {
        let name = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty
    }
    
    /// Adds a new Project to CoreData.
    func addProject() {
        log.debug("Adding a project")
        guard !addButtonDisabled else {
            log.debug("Failed to add project, the add button is disabled.")
            return
        }
        let _ = Project(name: projectName, startDate: startDate, context: viewContext)
        
        do {
            try viewContext.save()
            log.debug("Successfully saved Project to view context's store.")
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
