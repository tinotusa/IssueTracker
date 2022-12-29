//
//  HomeViewModelTests.swift
//  HomeViewModelTests
//
//  Created by Tino on 26/12/2022.
//

import XCTest
@testable import IssueTracker

final class HomeViewModelTests: XCTestCase {
    var viewModel = HomeViewModel()
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testDefaultState() {
        XCTAssertEqual(viewModel.title, "Projects", "Expected title to be Projects")
        XCTAssertFalse(viewModel.showingAddProjectView, "Expected showingAddProjectView  to be false.")
        XCTAssertFalse(viewModel.showingEditProjectView, "Expected showingEditProjectView to be false.")
        XCTAssertFalse(viewModel.showingDeleteProjectView, "Expected showingDeleteProjectView to be false.")
    }
}
