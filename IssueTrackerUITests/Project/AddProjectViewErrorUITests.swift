//
//  AddProjectViewErrorUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class AddProjectViewErrorUITests: XCTestCase {
    private var app: IssueTrackerApp!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = IssueTrackerApp()
        app.launchArguments.append(contentsOf: ["-ui-testing", "-save-throws-error"])
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddProjectThrowsError() throws {
        let project = try app.addProject()
        try project.enterProjectName("New project")
        try project.tapAddProjectButton()
        
        let errorTitle = app.staticTexts["errorTitle"]
        XCTAssertTrue(errorTitle.waitForExistence(timeout: 5), "An error sheet should be shown.")
        let errorMessage = app.staticTexts["errorMessage"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 5), "Error sheet with error message should exist.")
    }
}
