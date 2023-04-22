//
//  ProjectData.swift
//  IssueTracker
//
//  Created by Tino on 22/4/2023.
//

import Foundation

/// Data for a Project.
struct ProjectProperties: Equatable {
    /// The name of the project.
    var name = ""
    /// The date the project was started.
    var startDate: Date = .now
}

extension ProjectProperties {
    /// Checks if the given inputs are valid.
    /// - Returns: `True` if all the input fields have valid input. `False` otherwise.
    func isValidForm() -> Bool {
        let result = Self.validateProjectName(name)
        switch result {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    /// Checks that the given project name is valid.
    /// - Parameter name: The project name to check.
    /// - Returns: A Result with a `Bool` if successful or a `ValidationError` otherwise.
    static func validateProjectName(_ name: String) -> Result<Bool, ValidationError> {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            return .failure(.invalidInput(message: "Name cannot be empty"))
        }
        
        let filteredName = name.filter { char in
            var validChars = CharacterSet.letters
            validChars = validChars.union(.decimalDigits)
            validChars.insert(charactersIn: " .-")
            return char.unicodeScalars.allSatisfy { validChars.contains($0) }
        }
        
        if filteredName == name {
            return .success(true)
        } else {
            return .failure(.invalidInput(message: "Name cannot contain special characters."))
        }
    }
}
