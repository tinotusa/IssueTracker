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
}
