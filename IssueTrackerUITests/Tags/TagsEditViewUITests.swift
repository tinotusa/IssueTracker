//
//  TagsEditViewUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class TagsEditViewUITests: XCTestCase {
    private var app: XCUIApplication!
    private var projectHelper: AddProjectHelper!
    
    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()
        
        projectHelper = AddProjectHelper(app: app, timeout: 5)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEditTagsSheetAppears() throws {
        projectHelper.tapAddProjectButton()
        let name = "Test project"
        projectHelper.addProject(named: name)
        projectHelper.tapProject(named: name)
        projectHelper.tapMenuButton()
        let editButton = app.buttons["tagsEditButton"]
        XCTAssertTrue(editButton.exists, "Edit menu button should exist.")
        editButton.tap()
        
        let closeButton = app.buttons["closeButton"]
        let tagsEditbutton = app.buttons["editButton"]
        let deleteAllButton = app.buttons["deleteAllButton"]
        
        XCTAssertTrue(closeButton.exists, "Close button for TagsEditView should be visible.")
        XCTAssertTrue(tagsEditbutton.exists, "Edit button for TagsEditView should be visible.")
        XCTAssertTrue(deleteAllButton.exists, "delete all button for TagsEditView should be visible.")
    }
}
