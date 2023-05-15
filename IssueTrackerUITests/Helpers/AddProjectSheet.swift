//
//  AddProjectSheet.swift
//  IssueTrackerUITests
//
//  Created by Tino on 15/5/2023.
//

import Foundation

class AddProjectSheet: IssueTrackerUIElement {
    
    func enterProjectName(_ name: String) throws {
        let field = element.textFields["AddProjectView-projectName"]
        if !field.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Project name field doesn't exist.")
        }
        field.tap()
        field.typeText("\(name)\n")
    }
    
    func enterDate(_ predicate: NSPredicate) throws {
        let button = element.buttons.matching(predicate).firstMatch
        
        if !button.waitForExistence(timeout: 5) {
            throw IssueTrackerError.elementDoesNotExist(message: "Date matching predicate doesn't exist.")
        }
        button.tap()
    }
}
