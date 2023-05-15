//
//  IssueTrackerUIElement.swift
//  IssueTrackerUITests
//
//  Created by Tino on 15/5/2023.
//

import XCTest

class IssueTrackerUIElement {
    let app: XCUIApplication
    let element: XCUIElement
    
    init(app: XCUIApplication, element: XCUIElement) {
        self.app = app
        self.element = element
    }
}
