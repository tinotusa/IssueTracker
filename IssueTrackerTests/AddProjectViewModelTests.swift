//
//  AddProjectViewModelTests.swift
//  IssueTrackerTests
//
//  Created by Tino on 29/12/2022.
//

import XCTest
@testable import IssueTracker

final class AddProjectViewModelTests: XCTestCase {
    let viewModel = AddProjectViewModel(context: PersistenceController(inMemory: true).container.viewContext)
    
    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        
    }

    func testDefaultState() throws {
        XCTAssertTrue(viewModel.projectName.isEmpty, "Expected project name to be empty")
        XCTAssertTrue(viewModel.addButtonDisabled, "Expected the add button to be disabled since the project name is empty.")
    }
    
    func testAddProjectWithNoInput() {
        XCTAssertTrue(viewModel.addButtonDisabled, "Expected add button to be disabled.")
        let successfullyAdded = viewModel.addProject()
        XCTAssertFalse(successfullyAdded, "Expected addProject to return false.")
    }
    
    func testAddProjectWithInput() {
        viewModel.projectName = "example name"
        viewModel.startDate = .now
        XCTAssertFalse(viewModel.addButtonDisabled, "Expected the add button to be enabled.")
        let success = viewModel.addProject()
        XCTAssertTrue(success, "Expected the addProject function to return true.")
    }
    
    func testFilterName() {
        let characters = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890\n\t\\,./;'[]=)(*&^%$#@!~")
        var name = ""
        for _ in 0 ..< 26 {
            name += String(characters.randomElement()!)
        }
        viewModel.projectName = name
        viewModel.filterName(name)
        var validCharacters = CharacterSet.alphanumerics
        validCharacters.formUnion(.whitespaces)
        let result = viewModel.projectName.rangeOfCharacter(from: validCharacters) != nil
        print(name)
        print(viewModel.projectName)
        XCTAssertTrue(result, "Expected the filtered name to only contain letters and spaces.")
    }
}
