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
