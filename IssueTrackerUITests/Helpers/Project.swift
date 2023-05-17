//
//  Project.swift
//  IssueTrackerUITests
//
//  Created by Tino on 15/5/2023.
//

import Foundation

class Project: IssueTrackerUIElement {
    func tapAddIssueButton() throws -> AddIssueSheet {
        let button = app.buttons["addIssueButton"]
        
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Add issue button doesn't exist.")
        }
        button.tap()
        let issueScrollView = app.scrollViews["issuesList"]
        
        if !issueScrollView.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Issue form doesn't exist.")
        }
        
        return AddIssueSheet(app: app, element: element)
    }
    
    func tapMenuButton() throws -> ProjectMenu {
        let menuButton = app.buttons["toolbarMenuButton"]
        if !menuButton.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Menu button doesn't exist.")
        }
        menuButton.tap()
        
        return ProjectMenu(app: app, element: menuButton)
    }
}

class ProjectMenu: IssueTrackerUIElement {
    func tapDeleteProjectButton() throws {
        let button = app.buttons["deleteProjectButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Delete menu button doesn't exist.")
        }
        button.tap()
    }
    
    func tapEditTagsButton() throws {
        let button = app.buttons["tagsEditButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Edit tags buttons doesn't exiest.")
        }
        button.tap()
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

class EditProjectSheet: IssueTrackerUIElement {
    func enterName(_ name: String) throws -> EditProjectSheet {
        let field = app.textFields["editProject-nameField"]
        if !field.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Project name field does't exist.")
        }
        field.tap()
        field.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        
        app.keys["delete"].tap()
        field.typeText(name)
        
        return EditProjectSheet(app: app, element: element)
    }
    
    func selectDate(predicate: NSPredicate) throws -> EditProjectSheet {
        let dateButton = app.buttons.matching(predicate).firstMatch
        if !dateButton.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Date button doesn't exist.")
        }
        dateButton.tap()
        return EditProjectSheet(app: app, element: element)
    }
    
    func tapCancelButton() throws {
        let button = app.buttons["editProject-cancelButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Cancel button doesn't exist.")
        }
        button.tap()
    }
    
    func tapSaveButton() throws {
        let button = app.buttons["editProject-saveButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Save changes button doesn't exist.")
        }
        if !button.isEnabled {
            throw IssueTrackerError.disabledButton(message: "Save changes button is disabled.")
        }
        button.tap()
    }
}
