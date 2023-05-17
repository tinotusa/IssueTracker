//
//  TagsEditViewUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class TagsEditViewUITests: XCTestCase {
    private var app: IssueTrackerApp!
    
    override func setUpWithError() throws {
        continueAfterFailure = false

        app = IssueTrackerApp()
        app.launchArguments.append(contentsOf: ["-ui-testing", "-add-preview-data"])
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEditTagsSheetAppears() throws {
        let project = try app.tapProject(named: "New project")
        _ = try project.tapMenuButton()
            .tapEditTagsButton()
        
        let tagsScrollView = app.navigationBars["Edit tags"]
        
        XCTAssertTrue(tagsScrollView.waitForExistence(timeout: 5), "TagsEditView should exist.")
    }
    
    func testTagIsEdittedSuccessfully() throws {
        let name = "test"
        let tag = app.buttons[name]
        
        let editSheet = try app.tapProject(named: "New project")
            .tapMenuButton()
            .tapEditTagsButton()
        XCTAssertTrue(tag.exists, "Tag called \(name) should exist before delete.")
        
        try editSheet.deleteTag(named: name)
        
        XCTAssertFalse(tag.exists)
    }
    
    func testTagEditSaveSuccessfully() throws {
        let nameToChange = "test"
        let tagEditSheet = try app.tapProject(named: "New project")
            .tapMenuButton()
            .tapEditTagsButton()
            .tapTag(named: nameToChange)
        let tagName = app.buttons[nameToChange].value as! String
        
        let newName = "new name"
        try tagEditSheet
            .enterName(newName)
            .tapSaveButton()
        
        XCTAssertNotEqual(tagName, newName, "Tag should have a different name.")
    }
}
