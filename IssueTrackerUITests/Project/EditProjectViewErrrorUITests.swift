//
//  EditProjectViewErrrorUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 17/5/2023.
//

import XCTest

final class EditProjectViewErrrorUITests: XCTestCase {
    private var app: IssueTrackerApp!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = IssueTrackerApp()
        app.launchArguments.append(contentsOf:  ["-ui-testing", "-add-preview-data", "-save-throws-error"])
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEditProjectThrowsError() throws {
        try app.tapProject(named: "New project")
            .tapMenuButton()
            .tapEditProjectButton()
            .enterName("This change wont save")
            .tapSaveButton()
        
        let errorMessage = app.staticTexts["errorMessage"]
        XCTAssertTrue(errorMessage.waitForExistence(timeout: 5), "Error sheet should exist.")
    }
}
