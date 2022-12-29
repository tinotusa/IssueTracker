//
//  DeleteProjectViewModelTests.swift
//  IssueTrackerTests
//
//  Created by Tino on 29/12/2022.
//

import XCTest
import CoreData
@testable import IssueTracker

final class DeleteProjectViewModelTests: XCTestCase {
    var viewModel: DeleteProjectViewModel!
    var project: Project!
    
    override func setUpWithError() throws {
        let viewContext = PersistenceController(inMemory: true).container.viewContext
        project = Project.example(context: viewContext)
        viewModel = DeleteProjectViewModel(viewContext: viewContext)
    }

    override func tearDownWithError() throws {
        
    }

    func testDefaultState() throws {
        XCTAssertNil(viewModel.selectedProject, "Expected the selected project to be nil.")
        XCTAssertFalse(viewModel.showingDeleteProjectDialog, "Expected showing delete dialog to be false.")
    }

    func testDeleteWithNoSelectedProject() {
        let didDelete = viewModel.deleteProject()
        XCTAssertFalse(didDelete, "Expected didDelete to be false since this wasn't a valid delete.")
    }
    
    func testSelectProject() {
        viewModel.selectedProject = project
        XCTAssertTrue(viewModel.showingDeleteProjectDialog, "Expected the delete dialog to be true since a project has been selected.")
    }

    func testDeleteProject() {
        viewModel.selectedProject = project
        XCTAssertTrue(viewModel.showingDeleteProjectDialog, "Expected the delete dialog to be true since a project has been selected.")
        let didDelete = viewModel.deleteProject()
        XCTAssertTrue(didDelete, "Expected didDelete to be true since this was a valid delete.")
    }
}
