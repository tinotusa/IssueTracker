//
//  AddIssueViewErrorUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 15/5/2023.
//

import XCTest

final class AddIssueViewErrorUITests: XCTestCase {
    private var app: IssueTrackerApp!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = IssueTrackerApp()
        app.launchArguments.append(contentsOf: ["-ui-testing", "-add-preview-data"])
        app.launchEnvironment["addIssueViewThrowsError"] = "true"
        app.launch()
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddIssueThrowsError() throws {
        let project = try app.tapProject(named: "New project")
        let issueSheet = try project.tapAddIssueButton()
        try issueSheet.closeSheet()
    }
}
