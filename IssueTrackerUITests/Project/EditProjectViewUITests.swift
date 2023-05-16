//
//  EditProjectViewUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 16/5/2023.
//

import XCTest

final class EditProjectViewUITests: XCTestCase {
    private var app: IssueTrackerApp!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        
        continueAfterFailure = false
        app = IssueTrackerApp()
        app.launchArguments.append(contentsOf: ["-ui-testing", "-add-preview-data"])
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEditProjectSheetAppears() throws {
        let projectList = try app.tapProject(named: "New project")
        _ = try projectList
            .tapMenuButton()
            .tapEditProjectButton()
        
        let nameField = app.textFields["editProject-nameField"]
        let datePicker = app.datePickers["editProject-datePicker"]
        let saveButton = app.buttons["saveChangesButton"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5), "Project name field should exist.")
        XCTAssertTrue(datePicker.waitForExistence(timeout: 5), "Project date picker should exist.")
        XCTAssertTrue(saveButton.waitForExistence(timeout: 5), "Save changes button should exist.")
    }
    
    func testEditProjectSheetCancel() throws {
        let projectList = try app.tapProject(named: "New project")
        try projectList
            .tapMenuButton()
            .tapEditProjectButton()
            .tapCancelButton()
        
        let projectNameField = app.textFields["editProject-nameField"]
        XCTAssertFalse(projectNameField.waitForExistence(timeout: 5), "Project name field should not exist after tapping cancel button.")
    }
    
    func testEditChangesSaveSuccessfully() throws {
        let projectName = "New project"
        let projectPredicate = NSPredicate(format: "identifier CONTAINS %@", projectName)
        let oldCount = app.staticTexts.matching(projectPredicate).count
        let datePredicate = NSPredicate(format: "label CONTAINS %@", "Today")
        
        try app.tapProject(named: projectName)
            .tapMenuButton()
            .tapEditProjectButton()
            .enterName("Changed name")
            .selectDate(predicate: datePredicate)
            .tapSaveButton()
        
        let newCount = app.staticTexts.matching(projectPredicate).count
        XCTAssertNotEqual(newCount, oldCount, "After changes there should not be equal projects with the changed name.")
    }
    
    func testDeletesSuccessfully() throws {
        let project = try app.tapProject(named: "New project")
        try project.tapMenuButton()
            .tapDeleteProjectButton()
        
        let deleteConfirmation = app.buttons["confirmationDeleteButton"]
        XCTAssertTrue(deleteConfirmation.waitForExistence(timeout: 5), "Delete confirmation button should exist.")
        deleteConfirmation.tap()
        
        XCTAssertFalse(project.element.exists, "Project should not exist after being deleted.")
    }
}
