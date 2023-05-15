//
//  IssueTrackerApp.swift
//  IssueTrackerUITests
//
//  Created by Tino on 15/5/2023.
//

import XCTest

enum IssueTrackerError: Error {
    case elementDoesNotExist(message: String)
    case disabledButton(message: String)
}

class IssueTrackerApp: XCUIApplication {
    func addProject() throws -> AddProjectSheet {
        let button = buttons["HomeView-addProjectButton"]
        button.tap()
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Add project sheet button doesn't exist.")
        }
        let projectForm = scrollViews["projectForm"]
        if !projectForm.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Add project view doesn't exist.")
        }
        return AddProjectSheet(app: self, element: projectForm)
    }
    
    func tapProject(named name: String) throws -> Project {
        let predicate = NSPredicate(format: "identifier CONTAINS %@", name)
        let project = buttons.matching(predicate).firstMatch
        if !project.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "No project with name: \(name)")
        }
        project.tap()
        let issuesList = scrollViews["issuesList"]
        
        if !issuesList.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Project issues list doesn't exist.")
        }
        return Project(app: self, element: issuesList)
    }
}
