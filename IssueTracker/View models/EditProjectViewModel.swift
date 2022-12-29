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
    private let log = Logger(subsystem: "com.tinotusa.IssueTracker", category: "EditProjectViewModel")
    
    init(project: Project, viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.project = project
        self.viewContext = viewContext
        self.projectName = project.name
        self.startDate = project.startDate
    }
}

extension EditProjectViewModel {
    func cancel() {
        if projectHasChanges {
            showingHasChangesConfirmationDialog = true
        }
    }
    
    func save() -> Bool {
        log.debug("Starting to save project edits...")
        guard projectHasChanges else {
            log.debug("Failed to save changes. Project has no changes.")
            return false
        }
        project.name = projectName
        project.startDate = startDate
        do {
            try viewContext.save()
            log.debug("Successfully saved project edits.")
            return true
        } catch {
            log.error("Failed to save changes. \(error)")
            return false
        }
    }
    
    var projectHasChanges: Bool {
        let dateOrder = Calendar.current.compare(self.startDate, to: project.startDate, toGranularity: .day)
        return self.projectName != project.name || dateOrder != .orderedSame
    }
}