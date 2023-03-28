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
    private lazy var persistenceController = PersistenceController.shared
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: DeleteProjectViewModel.self)
    )
}

extension DeleteProjectViewModel {
    /// Deletes the selected project from core data.
    /// - Returns: `true` if the delete was successful; `false` otherwise.
    func deleteProject() -> Bool {
        guard let selectedProject else {
            logger.debug("Failed to delete project. no project selected.")
            return false
        }
        logger.debug("Deleting project \(selectedProject.wrappedId)")
        do {
            try persistenceController.deleteObject(selectedProject)
            return true
        } catch {
            logger.error("Failed to delete project \(selectedProject.wrappedId). \(error)")
            return false
        }
    }
}
