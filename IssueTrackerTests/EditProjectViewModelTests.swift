//
//  EditProjectViewModelTests.swift
//  IssueTrackerTests
//
//  Created by Tino on 29/12/2022.
//

import XCTest
import CoreData
@testable import IssueTracker

final class EditProjectViewModelTests: XCTestCase {
    var viewModel: EditProjectViewModel!
    var viewContext: NSManagedObjectContext!
    var project: Project!
    override func setUpWithError() throws {
        
        viewContext = PersistenceController(inMemory: true).container.viewContext
        project = Project.example(context: viewContext)
        viewModel = EditProjectViewModel(project: project, viewContext: viewContext)
    }

    override func tearDownWithError() throws {
        
    }

    func testDefaultState() {
        XCTAssertFalse(viewModel.projectHasChanges, "Expected project has changes to be false.")
        XCTAssertEqual(viewModel.projectName, project.name, "Expected the set projectName to equal the given project's name.")
        XCTAssertEqual(viewModel.startDate, project.startDate, "Expected the set startDate to equal the given project's startDate.")
    }
    
    func testCancelWithNoChanges() {
        viewModel.cancel()
        XCTAssertFalse(viewModel.showingHasChangesConfirmationDialog, "Expected showing changes confirmation to be false after making no changes.")
    }
    
    func testCancel() {
        viewModel.projectName = "new name"
        viewModel.cancel()
        XCTAssertTrue(viewModel.projectHasChanges, "Expected projectHasChanges to be true.")
        XCTAssertTrue(viewModel.showingHasChangesConfirmationDialog, "Expected showing changes confirmation to be true after making an edit to the project name.")
    }
    
    func testWithoutChanges() {
        let didSave = viewModel.save()
        XCTAssertFalse(viewModel.projectHasChanges, "Expected projectHasChanges to be false.")
        XCTAssertFalse(didSave, "Expected to get false after trying to save without changes.")
    }
    
    func testSaveSuccessfully() {
        viewModel.projectName = "new name"
        XCTAssertTrue(viewModel.projectHasChanges, "Expected projectHasChanges to be true.")
        let didSave = viewModel.save()
        XCTAssertTrue(didSave, "Expected to get true after saving the project")
    }
}
