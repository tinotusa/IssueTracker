//
//  AddProjectViewErrorUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class AddProjectViewErrorUITests: XCTestCase {
    private var app: XCUIApplication!
    private var addProjectHelper: AddProjectHelper!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launchEnvironment["addIssueViewThrowsError"] = "true"
        app.launch()
        addProjectHelper = .init(app: app, timeout: 5)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAddProjectThrowsError() {
        addProjectHelper.tapAddButton()
        let name = UUID().uuidString
        addProjectHelper.addProject(named: name)
        let errorTitle = app.staticTexts["errorTitle"]
        XCTAssertTrue(errorTitle.waitForExistence(timeout: addProjectHelper.timeout), "An error sheet should be shown.")
        let errorMessage = app.staticTexts["errorMessage"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: addProjectHelper.timeout), "Error sheet with error message should exist.")
        let expectedErrorMessage = "Failed to add project."
        XCTAssertEqual(errorMessage.label, expectedErrorMessage, "Recieved incorrect error message. Expected: \(expectedErrorMessage) got: \(errorMessage.label)")
    }
}
