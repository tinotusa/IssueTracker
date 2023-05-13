//
//  HomeViewUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 12/5/2023.
//

import XCTest

final class HomeViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var timeout: TimeInterval!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        timeout = 5
        app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddProjectShowsAddProjectSheet() {
        tapAddButton()
    }
    
    func testDeleteProjectSucceds() {
        tapAddButton()
        
        let name = UUID().uuidString
        addProject(named: name)
        tapProject(named: name)
        tapMenuButton()
        let deleteButton = app.buttons["deleteProjectButton"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: timeout), "Delete project button should exist.")
        deleteButton.tap()
        
        let confirmationDeleteButton = app.buttons["confimationDeleteButton"]
        XCTAssertTrue(confirmationDeleteButton.waitForExistence(timeout: timeout), "Comfirnation dialog delete button should exist.")
        confirmationDeleteButton.tap()
        
        let project = app.buttons["\(name)-\(name)"].firstMatch
        XCTAssertFalse(project.waitForExistence(timeout: timeout), "Project named: \(name) shouldn't exist.")
    }
    
    func testAddProjectViewCloseButton() {
        tapAddButton()
        let closeButton = app.buttons["AddProjectView-closeButton"]
        XCTAssertTrue(closeButton.isEnabled, "Close button should be enabled.")
        XCTAssertTrue(closeButton.waitForExistence(timeout: timeout), "Close button should be on screen.")
        closeButton.tap()
        XCTAssertEqual(app.sheets.count, 0, "Add project view sheet should be closed.")
    }
}

private extension HomeViewUITests {
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
        
        XCTAssertFalse(projectNameField.waitForExistence(timeout: timeout), "Project name field shouldn't be on screen any more.")
        XCTAssertEqual(app.sheets.count, 0, "There should be no sheet visible.")
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
