//
//  ProjectMenu.swift
//  IssueTrackerUITests
//
//  Created by Tino on 17/5/2023.
//

import Foundation

class ProjectMenu: IssueTrackerUIElement {
    func tapDeleteProjectButton() throws {
        let button = app.buttons["deleteProjectButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Delete menu button doesn't exist.")
        }
        button.tap()
    }
    
    func tapEditTagsButton() throws -> TagsEditSheet {
        let button = app.buttons["tagsEditButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Edit tags buttons doesn't exiest.")
        }
        button.tap()
        
        return TagsEditSheet(app: app, element: element)
    }
    
    func tapEditProjectButton() throws -> EditProjectSheet {
        let button = app.buttons["editProjectButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Edit project button doesn't exist.")
        }
        button.tap()
        
        return EditProjectSheet(app: app, element: element)
    }
}
