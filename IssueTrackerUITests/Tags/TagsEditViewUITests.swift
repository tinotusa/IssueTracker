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
        try project.tapMenuButton()
            .tapEditTagsButton()
        
        let tagsScrollView = app.navigationBars["Edit tags"]
        
        XCTAssertTrue(tagsScrollView.waitForExistence(timeout: 5), "TagsEditView should exist.")
    }
}
