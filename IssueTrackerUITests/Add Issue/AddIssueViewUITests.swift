//
//  AddIssueViewUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class AddIssueViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var projectHelper: AddProjectHelper!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        projectHelper = .init(app: app, timeout: 5)
        app.launch()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCancelAddIssueSheet() {
        projectHelper.tapAddProjectButton()
        
        let projectName = "New project"
        projectHelper.addProject(named: projectName)
        
        projectHelper.tapProject(named: projectName)
        projectHelper.tapAddIssueButton()
        let button = app.buttons["cancelButton"]
        XCTAssertTrue(button.exists, "Cancel button should exist.")
        button.tap()
        let issuesListPredicate = NSPredicate(format: "identifier CONTAINS %@", "issuesList-")
        let issuesList = app.staticTexts.containing(issuesListPredicate).firstMatch
        
        XCTAssertTrue(issuesList.waitForExistence(timeout: projectHelper.timeout), "Issues list should exist.")
    }
    
    func testAddIssue() throws {
        projectHelper.tapAddProjectButton()
        let projectName = "New project"
        projectHelper.addProject(named: projectName)
        projectHelper.tapProject(named: projectName)
        projectHelper.tapAddIssueButton()
        projectHelper.addIssue(name: "issue name here")
    }
}
