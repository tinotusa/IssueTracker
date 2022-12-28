//
//  AddProjectViewModel.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import Foundation
import SwiftUI

final class AddProjectViewModel: ObservableObject {
    private let viewContext = PersistenceController.shared
    let projectNamePrompt: LocalizedStringKey = "Project name:"
    let datePrompt: LocalizedStringKey = "Start date:"
    let projectNamePlaceholder: LocalizedStringKey = "Project name"
    let title: LocalizedStringKey = "New project"
    let addButtonTitle: LocalizedStringKey = "Add project"
    
    @Published var projectName = ""
    @Published var startDate = Date()

    var addButtonDisabled: Bool {
        let name = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty
    }
    
    func addProject() {
        
    }
    
    /// Filters the given name by removing non alphanumerics and non spaces.
    /// - Parameter name: The name to filter.
    func filterName(_ name: String) {
        var invalidCharacters = CharacterSet.alphanumerics
        invalidCharacters.formUnion(.whitespaces)
        invalidCharacters.invert()
        let filteredValue = name.components(separatedBy: invalidCharacters).joined(separator: "")
        if projectName != filteredValue {
            projectName = filteredValue
        }
    }
}
