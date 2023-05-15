//
//  AddProjectViewUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class AddProjectViewUITests: XCTestCase {
    private var app: IssueTrackerApp!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    
        app = IssueTrackerApp()
        app.launchArguments.append(contentsOf: ["-ui-testing", "-add-preview-data"])
        app.launchEnvironment["addIssueViewThrowsError"] = "false"
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // TODO: Move this test to issuelistview ui tests later
    func testDeleteProjectSucceds() throws {
        let projectPredicate = NSPredicate(format: "identifier CONTAINS %@", "\(name)")
        let oldButtonCount = app.buttons.count
        
        let project = try app.tapProject(named: "New project")
        try project.tapMenuButton()
            .tapDeleteButton()
        
        let confirmationDeleteButton = app.buttons["confimationDeleteButton"]
        XCTAssertTrue(confirmationDeleteButton.waitForExistence(timeout: 5), "Comfirnation dialog delete button should exist.")
        confirmationDeleteButton.tap()
        
        let newButtonCount = app.buttons.matching(projectPredicate).count
        XCTAssertLessThan(newButtonCount, oldButtonCount, "There should be 1 less project after calling delete.")
    }
    
    func testAddProjectViewCloseButton() throws {
        try app.addProject()
            .tapCancelButton()
        
        let projectsList = app.scrollViews["projectsList"]
        XCTAssertTrue(projectsList.waitForExistence(timeout: 5), "Projects list should exist.")
    }
}
