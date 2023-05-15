//
//  AddProjectSheet.swift
//  IssueTrackerUITests
//
//  Created by Tino on 15/5/2023.
//

import Foundation

class AddProjectSheet: IssueTrackerUIElement {
    func enterProjectName(_ name: String) throws {
        let field = element.textFields["AddProjectView-projectName"]
        if !field.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Project name field doesn't exist.")
        }
        field.tap()
        field.typeText("\(name)\n")
    }
    
    func enterDate(_ predicate: NSPredicate) throws {
        let button = element.buttons.matching(predicate).firstMatch
        
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Date matching predicate doesn't exist.")
        }
        button.tap()
    }
    
    func tapCancelButton() throws {
        let closeButton = app.buttons["AddProjectView-closeButton"]
        if !closeButton.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Close button should be on screen.")
        }
        if !closeButton.isEnabled {
            throw IssueTrackerError.disabledButton(message: "Close button should be enabled.")
        }
        closeButton.tap()
    }
    
    func tapAddProjectButton() throws {
        let button = app.buttons["AddProjectView-addProjectToolbarButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Add project button doesn't exist.")
        }
        button.tap()
    }
}
