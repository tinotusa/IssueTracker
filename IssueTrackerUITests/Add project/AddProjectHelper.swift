//
//  AddProjectHelper.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class AddProjectHelper {
    let app: XCUIApplication
    let timeout: TimeInterval
    
    init(app: XCUIApplication, timeout: TimeInterval) {
        self.app = app
        self.timeout = timeout
    }
    
    func tapAddProjectButton() {
        let addProjectButton = app.buttons["HomeView-addProjectButton"]
        XCTAssertTrue(addProjectButton.exists, "Add project button should exist.")
        addProjectButton.tap()
    }
    
    func addProject(named name: String) {
        let projectNameField = app.textFields["AddProjectView-projectName"]
        let datePicker = app.datePickers["datePicker"]
        let addProjectButton = app.buttons["AddProjectView-addProjectButton"]
        let addProjectToolbarButton = app.buttons["AddProjectView-addProjectToolbarButton"]
        
        XCTAssertTrue(addProjectButton.exists, "Add project button should exist.")
        XCTAssertTrue(addProjectToolbarButton.exists, "Add project toolbar button should exist.")
        XCTAssertFalse(addProjectButton.isEnabled, "Add project button should be disabled.")
        XCTAssertFalse(addProjectToolbarButton.isEnabled, "Add project toolbar button should be disabled.")
        
        XCTAssertTrue(projectNameField.exists, "Project name field should exist.")
        XCTAssertTrue(datePicker.exists, "Date picker should exist.")
        
        projectNameField.tap()
        projectNameField.typeText(name)
        
        let calendarButtonPredicate = NSPredicate(format: "label CONTAINS %@", "Today")
        
        let calendarButton = app.buttons.matching(calendarButtonPredicate).firstMatch
        XCTAssertTrue(calendarButton.exists, "Date picker button should exist.")
        calendarButton.tap()
        
        XCTAssertTrue(addProjectButton.isEnabled, "Add project button should be enabled.")
        addProjectButton.tap()
    }
    
    func tapProject(named name: String) {
        let predicate = NSPredicate(format: "identifier CONTAINS %@", "\(name)")
        let project = app.buttons.matching(predicate).firstMatch
        XCTAssertTrue(project.exists, "Project row with name: \(name) should exist.")
        project.tap()
    }
    
    func tapMenuButton() {
        let button = app.buttons["toolbarMenuButton"]
        XCTAssertTrue(button.exists, "Menu button should exist.")
        button.tap()
    }
    
    func tapAddIssueButton() {
        let button = app.buttons["addIssueButton"]
        XCTAssertTrue(button.exists, "Add issue button should exist.")
        button.tap()
    }
    
    enum Priority: String {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    func addIssue(
        name: String,
        description: String? = nil,
        priority: Priority = .low,
        tags: [String] = []
    ) {
        // Input fields
        let nameField = app.textFields["nameField"]
        let descriptionField = app.textViews["descriptionField"]
        let addTagsButton = app.buttons["addTagsButton"]
        
        XCTAssertTrue(nameField.exists, "Name field should exist.")
        XCTAssertTrue(descriptionField.exists, "Description field should exist.")

        XCTAssertTrue(addTagsButton.exists, "Add tags button should exist.")

        // Buttons
        let cancelButton = app.buttons["cancelButton"]
        let addIssueButton = app.buttons["AddIssueView-addIssueButton"]
        let priorityButton = app.buttons[priority.rawValue]
        let tagsButton = app.buttons["addTagsButton"]
        
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist.")
        XCTAssertTrue(addIssueButton.exists, "Add issue button should exist.")
        XCTAssertFalse(addIssueButton.isEnabled, "Add issue button should not be enabled.")
        XCTAssertTrue(cancelButton.isEnabled, "Cancel button should not be enabled.")
        XCTAssertTrue(priorityButton.exists, "Priority button \(priority.rawValue) should exist.")
        XCTAssertTrue(tagsButton.exists, "Add tags button should exist.")
        
        nameField.tap()
        nameField.typeText(name)
        if let description {
            descriptionField.tap()
            descriptionField.typeText(description)
        }

        priorityButton.tap()
        
        // tap tags and input tags
        tagsButton.tap()
        let tagName = "new tag"
        addTag(named: tagName)
        let doneButton = app.buttons["TagSelectionView-doneButton"]
        XCTAssertTrue(doneButton.exists, "Add tag view done button should exist.")
        doneButton.tap()
        
        XCTAssertTrue(addTagsButton.label.contains("1 tag"), "Add tag button should have label containing 1 tag.")
        
        addIssueButton.tap()
        let issueNamePredicate = NSPredicate(format: "identifier CONTAINS %@", "\(name)")
        let issue = app.staticTexts.matching(issueNamePredicate).firstMatch
        
        XCTAssertTrue(issue.waitForExistence(timeout: timeout), "Issue with name: \(name) should exist.")
    }
    
    func addTag(named name: String) {
        let inputField = app.textFields["tagInputField"]
        XCTAssertTrue(inputField.exists, "Tag input field should exist.")
        inputField.tap()
        inputField.typeText("\(name)")
        let submitButton = app.keyboards.buttons["Return"]
        
        XCTAssertTrue(submitButton.exists, "Keyboard submit button should exist")
        submitButton.tap()
    }
}
