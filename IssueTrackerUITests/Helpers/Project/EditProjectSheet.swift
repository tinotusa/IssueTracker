//
//  EditProjectSheet.swift
//  IssueTrackerUITests
//
//  Created by Tino on 17/5/2023.
//

import Foundation

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
