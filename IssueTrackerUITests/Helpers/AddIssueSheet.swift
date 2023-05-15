//
//  AddIssueSheet.swift
//  IssueTrackerUITests
//
//  Created by Tino on 15/5/2023.
//

import Foundation

class AddIssueSheet: IssueTrackerUIElement {
    func closeSheet() throws {
        let cancelButton = app.buttons["cancelButton"]
        if !cancelButton.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Cancel button doesn't exist.")
        }
        if !cancelButton.isEnabled {
            throw IssueTrackerError.disabledButton(message: "The cancel button is disabled.")
        }
        cancelButton.tap()
    }
}
