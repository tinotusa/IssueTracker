//
//  TagsEditSheet.swift
//  IssueTrackerUITests
//
//  Created by Tino on 17/5/2023.
//

import Foundation

class TagsEditSheet: IssueTrackerUIElement {
    func tapEditButton() throws -> TagsEditSheet {
        let editButton = app.buttons["editButton"]
        if !editButton.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Edit button doesn't exist.")
        }
        editButton.tap()
        
        return TagsEditSheet(app: app, element: element)
    }
    
    func deleteTag(named name: String) throws {
        let predicate = NSPredicate(format: "identifier CONTAINS %@", name)
        let tag = app.buttons.matching(predicate).firstMatch
        if !tag.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Tag with name: \(name) doesn't exist.")
        }
        
        tag.swipeLeft()
        
        app.buttons["Delete"].tap()
    }
    
    func tapTag(named name: String) throws -> TagEditSheet {
        let button = app.buttons[name]
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Tag named \(name) doesn't exist.")
        }
        button.tap()
        return TagEditSheet(app: app, element: element)
    }
}
