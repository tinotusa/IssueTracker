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
    func tapDeleteButton() throws {
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
}
