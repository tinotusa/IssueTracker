//
//  ContentViewUITests.swift
//  IssueTrackerUITests
//
//  Created by Tino on 12/5/2023.
//

import XCTest
@testable import IssueTracker

final class ContentViewUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        app = XCUIApplication()
        app.launchArguments.append("-ui-testing")
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHomeViewIsVisible() throws {
        let isHittable = app.staticTexts["Projects"].isHittable
        XCTAssertTrue(isHittable, "Projects text should be visible.")
    }
}
