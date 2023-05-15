//
//  AddProjectViewUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class AddProjectViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var timeout: TimeInterval!
    private var addProjectHelper: AddProjectHelper!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        timeout = 5
        app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launchEnvironment["addIssueViewThrowsError"] = "false"
        app.launch()
        addProjectHelper = .init(app: app, timeout: timeout)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // TODO: Move this test to issuelistview ui tests later
    func testDeleteProjectSucceds() {
        addProjectHelper.tapAddProjectButton()
        
        let name = UUID().uuidString
        addProjectHelper.addProject(named: name)
        addProjectHelper.tapProject(named: name)
        addProjectHelper.tapMenuButton()
        let deleteButton = app.buttons["deleteProjectButton"]
        XCTAssertTrue(deleteButton.exists, "Delete project button should exist.")
        deleteButton.tap()
        
        let confirmationDeleteButton = app.buttons["confimationDeleteButton"]
        XCTAssertTrue(confirmationDeleteButton.waitForExistence(timeout: addProjectHelper.timeout), "Comfirnation dialog delete button should exist.")
        confirmationDeleteButton.tap()
        
        let projectPredicate = NSPredicate(format: "identifier CONTAINS %@", "\(name)")
        let project = app.buttons.matching(projectPredicate).firstMatch
        XCTAssertFalse(project.waitForExistence(timeout: timeout), "Project named: \(name) shouldn't exist.")
    }
    
    func testAddProjectViewCloseButton() {
        addProjectHelper.tapAddProjectButton()
        let closeButton = app.buttons["AddProjectView-closeButton"]
        XCTAssertTrue(closeButton.isEnabled, "Close button should be enabled.")
        XCTAssertTrue(closeButton.waitForExistence(timeout: timeout), "Close button should be on screen.")
        closeButton.tap()
        let noProjectsText = app.staticTexts["noProjectsText"]
        XCTAssertTrue(noProjectsText.waitForExistence(timeout: addProjectHelper.timeout), "No projects text should be displayed. Since no project was added.")
    }
}
