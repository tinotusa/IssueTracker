//
//  TagEditSheet.swift
//  IssueTrackerUITests
//
//  Created by Tino on 17/5/2023.
//

import Foundation

class TagEditSheet: IssueTrackerUIElement {
    func enterName(_ name: String) throws -> TagEditSheet {
        let field = app.textFields["editTagView-nameField"]
        if !field.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Name input field doesn't exist.")
        }
        field.tap()
        field.tap(withNumberOfTaps: 3, numberOfTouches: 1)
        
        app.keys["delete"].tap()
        field.typeText(name)
        
        return TagEditSheet(app: app, element: element)
    }
    
    func tapSaveButton() throws {
        let button = app.buttons["editTagView-saveButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Save button doesn't exist.")
        }
        if !button.isEnabled {
            throw IssueTrackerError.disabledButton(message: "Save button is disabled.")
        }
        button.tap()
    }
}
