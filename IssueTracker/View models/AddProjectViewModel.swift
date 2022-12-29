//
//  AddProjectViewModel.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import os
import SwiftUI

final class AddProjectViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext
    let projectNamePrompt: LocalizedStringKey = "Project name:"
    let datePrompt: LocalizedStringKey = "Start date:"
    let projectNamePlaceholder: LocalizedStringKey = "Project name"
    let title: LocalizedStringKey = "New project"
    let addButtonTitle: LocalizedStringKey = "Add project"
    
    @Published var projectName = ""
    @Published var startDate = Date()

    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "AddProjectViewModel")
}

extension AddProjectViewModel {
    /// A boolean indication whether or not the add button is disabled.
    var addButtonDisabled: Bool {
        let name = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty
    }
    
    /// Adds a new Project to CoreData.
    /// - Returns: `true` if the project was added; `false` otherwise.
    func addProject() -> Bool {
        log.debug("Adding a project")
        guard !addButtonDisabled else {
            log.debug("Failed to add project, the add button is disabled.")
            return false
        }
        let project = Project(context: viewContext)
        project.name = projectName
        project.startDate = startDate
        project.id = UUID()
        project.dateCreated = .now
        
        do {
            try viewContext.save()
            log.debug("Successfully saved Project to view context's store.")
            return true
        } catch {
            log.error("Failed to save Project to view context's store.")
        }
        return false
    }
    
    /// Filters the given name by removing non alphanumerics and non spaces.
    /// - Parameter name: The name to filter.
    func filterName(_ name: String) {
        var invalidCharacters = CharacterSet.alphanumerics
        invalidCharacters.formUnion(.whitespaces)
        invalidCharacters.invert()
        let filteredValue = name.components(separatedBy: invalidCharacters).joined(separator: "")
        if projectName != filteredValue {
            projectName = filteredValue
        }
    }
}
