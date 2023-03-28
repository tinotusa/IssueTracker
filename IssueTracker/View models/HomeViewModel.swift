//
//  HomeViewModel.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import os
import SwiftUI
import CoreData

final class HomeViewModel: ObservableObject {
    let title: LocalizedStringKey = "Projects"
    
    /// The project selected for editing.
    @Published var selectedProject: Project?
    // A boolean indicating whether or not the AddProjectView is showing.
    @Published var showingAddProjectView = false
    // A boolean indicating whether or not the EditProjectView is showing.
    @Published var showingEditProjectView = false
    // A boolean indicating whether or not the DeleteProjectView is showing.
    @Published var showingDeleteProjectView = false
    
    private lazy var persistenceController = PersistenceController.shared
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: HomeViewModel.self)
    )
}

extension HomeViewModel {
    /// Deletes the given project for the view context.
    /// - Parameter project: The project to delete.
    func deleteProject(_ project: Project) {
        logger.debug("Deleting project \(project.wrappedId)")
        do {
            try persistenceController.deleteObject(project)
            logger.debug("Successfully deleted project.")
        } catch {
            logger.error("Failed to delete project: \(project.wrappedId). \(error)")
        }
    }
}
