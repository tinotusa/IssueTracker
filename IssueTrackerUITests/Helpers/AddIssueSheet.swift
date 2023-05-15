//
//  AddIssueSheet.swift
//  IssueTrackerUITests
//
//  Created by Tino on 15/5/2023.
//

import Foundation

class AddIssueSheet: IssueTrackerUIElement {
    func enterIssueName(_ name: String) throws -> AddIssueSheet {
        let field = app.textFields["nameField"]
        if !field.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Issue name field doesn't exist.")
        }
        field.tap()
        field.typeText("\(name)\n")
        return AddIssueSheet(app: app, element: element)
    }
    
    func enterDescription(_ description: String) throws -> AddIssueSheet {
        let field = app.textFields["descriptionField"]
        if !field.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Issue description field doesn't exist.")
        }
        field.tap()
        field.typeText("\(description)\n")
        return AddIssueSheet(app: app, element: element)
    }
    
    enum Priority: String, CustomStringConvertible {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var description: String {
            switch self {
            case .high: return rawValue
            case .low: return rawValue
            case .medium: return rawValue
            }
        }
    }
    
    func setPriority(to priority: Priority) throws -> AddIssueSheet {
        let button = app.buttons[priority.rawValue]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Priority: \(priority) doesn't exist.")
        }
        button.tap()
        return AddIssueSheet(app: app, element: element)
    }
    
    func tapAddTagsButton() throws -> AddTagsSheet {
        let button = app.buttons["addTagsButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Add tags button doesn't exist.")
        }
        button.tap()
        
        return AddTagsSheet(app: app, element: element)
    }
    
    func tapCancelButton() throws {
        let cancelButton = app.buttons["cancelButton"]
        if !cancelButton.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Cancel button doesn't exist.")
        }
        if !cancelButton.isEnabled {
            throw IssueTrackerError.disabledButton(message: "The cancel button is disabled.")
        }
        cancelButton.tap()
    }
    
    func tapAddIssueButton() throws {
        let addIssueButton = app.buttons["AddIssueView-addIssueButton"]
        if !addIssueButton.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Add issue button doesn't exist.")
        }
        if !addIssueButton.isEnabled {
            throw IssueTrackerError.disabledButton(message: "The add issue button is disabled.")
        }
        addIssueButton.tap()
    }
}

class AddTagsSheet: IssueTrackerUIElement {
    func enterTag(_ name: String) throws -> AddTagsSheet {
        let field = app.textFields["tagInputField"]
        
        if !field.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Tag input field doesn't exist.")
        }
        field.tap()
        field.typeText("\(name)")
        // TODO: Colour input here
        app.keyboards.buttons["Return"].tap()
        return AddTagsSheet(app: app, element: element)
    }
    
    func tapDoneButton() throws {
        let button = app.buttons["TagSelectionView-doneButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Cancel button doesn't exist.")
        }
        button.tap()
    }
    
    func tapCancelButton() throws {
        let button = app.buttons["TagSelectionView-cancelButton"]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Cancel button doesn't exist.")
        }
        button.tap()
    }
}
