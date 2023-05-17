//
//  AddIssueViewUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 14/5/2023.
//

import XCTest

final class AddIssueViewUITests: XCTestCase {
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
    
    func testCancelAddIssueSheet() throws {
        let project = try app.tapProject(named: "New project")
        try project.tapAddIssueButton()
            .tapCancelButton()
        
        let issuesNavigationBar = app.navigationBars["Issues"]
        XCTAssertTrue(issuesNavigationBar.waitForExistence(timeout: 5), "Issues list should exist.")
    }
    
    func testAddIssue() throws {
        let project = try app.tapProject(named: "New project")
        let issueName = "New issue"
        let addIssueSheet = try project.tapAddIssueButton()
            .enterIssueName(issueName)
            .setPriority(to: .medium)
        
        try addIssueSheet.tapAddTagsButton()
            .enterTag("new tag")
            .tapDoneButton()
        
        try addIssueSheet.tapAddIssueButton()
        
        let issuePredicate = NSPredicate(format: "label CONTAINS %@", issueName)
        let issues = app.staticTexts.matching(issuePredicate)
        
        XCTAssertGreaterThan(issues.count, 0, "Issues should be greater than one after adding a new issue.")
    }
}
