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
    
    func testNoProjectsTextIsVisible() {
        let text = app.staticTexts["noProjectsText"]
        XCTAssertTrue(text.waitForExistence(timeout: timeout), "No projects text should be visible.")
    }
    
    func testAddProjectShowsAddProjectSheet() {
        let addProjectButton = app.buttons["HomeView-addProjectButton"]
        XCTAssertTrue(addProjectButton.waitForExistence(timeout: timeout), "Add project button should exist.")
        addProjectButton.tap()
    }
}
