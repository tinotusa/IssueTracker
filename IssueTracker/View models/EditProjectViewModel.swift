//
//  EditProjectViewModel.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import Foundation
import CoreData
import os

final class EditProjectViewModel: ObservableObject {
    let project: Project
    @Published var showingHasChangesConfirmationDialog = false
    @Published var projectName = ""
    @Published var startDate = Date()
    private let viewContext: NSManagedObjectContext
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: EditProjectViewModel.self)
    )
    
    init(project: Project, viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.project = project
        self.viewContext = viewContext
        self.projectName = project.wrappedName
        self.startDate = project.wrappedStartDate
    }
}

extension EditProjectViewModel {
    func cancel() {
        if projectHasChanges {
            showingHasChangesConfirmationDialog = true
        }
    }
    
    @discardableResult
    @MainActor
    func save(persistenceController: PersistenceController) -> Bool {
        guard projectHasChanges else {
            logger.debug("Failed to save changes. Project has no changes.")
            return false
        }
        objectWillChange.send()
        project.name = projectName
        project.startDate = startDate
        
        let didSave = persistenceController.save()
        if didSave {
            logger.debug("Successfully saved project edits.")
        } else {
            logger.debug("Failed to save changes.")
        }
        return didSave
    }
    
    var projectHasChanges: Bool {
        let dateOrder = Calendar.current.compare(self.startDate, to: project.wrappedStartDate, toGranularity: .day)
        return self.projectName != project.name || dateOrder != .orderedSame
    }
}
