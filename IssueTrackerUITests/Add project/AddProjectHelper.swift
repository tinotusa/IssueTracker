//
//  AddProjectHelper.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class AddProjectHelper {
    let app: XCUIApplication
    let timeout: TimeInterval
    
    init(app: XCUIApplication, timeout: TimeInterval) {
        self.app = app
        self.timeout = timeout
    }
    
    func tapAddButton() {
        let addProjectButton = app.buttons["HomeView-addProjectButton"]
        XCTAssertTrue(addProjectButton.waitForExistence(timeout: timeout), "Add project button should exist.")
        addProjectButton.tap()
    }
    
    func addProject(named name: String) {
        let projectNameField = app.textFields["AddProjectView-projectName"]
        let datePicker = app.datePickers["datePicker"]
        let addProjectButton = app.buttons["AddProjectView-addProjectButton"]
        let addProjectToolbarButton = app.buttons["AddProjectView-addProjectToolbarButton"]
        
        XCTAssertTrue(addProjectButton.waitForExistence(timeout: timeout), "Add project button should exist.")
        XCTAssertTrue(addProjectToolbarButton.waitForExistence(timeout: timeout), "Add project toolbar button should exist.")
        XCTAssertFalse(addProjectButton.isEnabled, "Add project button should be disabled.")
        XCTAssertFalse(addProjectToolbarButton.isEnabled, "Add project toolbar button should be disabled.")
        
        XCTAssertTrue(projectNameField.waitForExistence(timeout: timeout), "Project name field should exist.")
        XCTAssertTrue(datePicker.waitForExistence(timeout: timeout), "Date picker should exist.")
        
        projectNameField.tap()
        projectNameField.typeText(name)
        
        let calendarButton = app.buttons["Friday, May 12"]
        XCTAssertTrue(calendarButton.waitForExistence(timeout: timeout), "Date picker button should exist.")
        calendarButton.tap()
        
        addProjectButton.tap()
    }
    
    func tapProject(named name: String) {
        let project = app.buttons["\(name)-\(name)"].firstMatch
        XCTAssertTrue(project.waitForExistence(timeout: timeout), "Project row with name: \(name) should exist.")
        project.tap()
    }
    
    func tapMenuButton(){
        let button = app.buttons["toolbarMenuButton"]
        XCTAssertTrue(button.waitForExistence(timeout: timeout), "Menu button should exist.")
        button.tap()
    }
}
