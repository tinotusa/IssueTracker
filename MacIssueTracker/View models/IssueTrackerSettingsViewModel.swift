//
//  IssueTrackerSettingsViewModel.swift
//  MacIssueTracker
//
//  Created by Tino on 26/1/2023.
//

import SwiftUI
import CoreData
import os

final class IssueTrackerSettingsViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: IssueTrackerSettingsViewModel.self)
    )
    
    /// Creates an IssueTrackerSetting view model.
    /// - Parameter viewContext: The view context of the settings.
    init(viewContext: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = viewContext
    }
}

extension IssueTrackerSettingsViewModel {
    /// Adds a new tag with N/A as its name.
    func addNewTag() {
        logger.trace("Adding a new empty tag.")
        _ = Tag.init(name: "N/A", context: viewContext)
        do {
            try viewContext.save()
            logger.trace("Successfully saved the new empty tag")
        } catch {
            viewContext.rollback()
            logger.error("Failed to save the new tag. \(error)")
        }
    }
    
    /// Removes tags with the same id.
    /// - Parameters:
    ///   - tags: All the tags in core data.
    ///   - tagIDs: The tag ids to be removed.
    func remove(tags: FetchedResults<Tag>, withIDs tagIDs: Set<Tag.ID>) {
        logger.trace("removing tags with the ids: \(tagIDs)")
        let tags = tags.filter { tagIDs.contains($0.wrappedId) }
        tags.forEach { viewContext.delete($0) }
        do {
            try viewContext.save()
            logger.trace("Successfully deleted tags with ids: \(tagIDs)")
        } catch {
            logger.error("Failed to delete tags with ids: \(tagIDs). \(error)")
        }
    }
}
