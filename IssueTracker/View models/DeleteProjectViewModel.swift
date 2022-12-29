//
//  DeleteProjectViewModel.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import Foundation
import CoreData
import os

final class DeleteProjectViewModel: ObservableObject {
    @Published var selectedProject: Project? {
        didSet {
            if selectedProject != nil {
                showingDeleteProjectDialog = true
            }
        }
    }
    @Published var showingDeleteProjectDialog = false
    
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "DeleteProjectViewModel")
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
}

extension DeleteProjectViewModel {
    /// Deletes the selected project from core data.
    /// - Returns: `true` if the delete was successful; `false` otherwise.
    func deleteProject() -> Bool {
        log.debug("Deleting project...")
        guard let selectedProject else {
            log.debug("Failed to delete project. no project selected.")
            return false
        }
        viewContext.delete(selectedProject)
        do {
            try viewContext.save()
            log.debug("Successfully deleted project.")
            return true
        } catch {
            log.error("Failed to delete project. \(error)")
            return false
        }
    }
}
