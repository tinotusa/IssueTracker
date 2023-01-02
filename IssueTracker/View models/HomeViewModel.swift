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
    
    private let viewContext: NSManagedObjectContext
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "HomeViewModel")
    
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
}

extension HomeViewModel {
    /// Deletes the given project for the view context.
    /// - Parameter project: The project to delete.
    func deleteProject(_ project: Project) {
        log.debug("Deleting project ...")
        
        viewContext.delete(project)
        do {
            try viewContext.save()
            log.debug("Successfully deleted project.")
        } catch {
            viewContext.rollback()
            log.error("Failed to delete project. \(error)")
        }
    }
}
