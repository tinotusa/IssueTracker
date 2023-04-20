//
//  AddProjectViewModel.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import os
import SwiftUI
import Combine

/// View model for `AddProjectView`
final class AddProjectViewModel: ObservableObject {
    /// The name of the project.
    @Published var projectName = ""
    /// The date the project was started.
    @Published var dateStarted: Date = .now
    
    /// A boolean value indicating whether or not the input fields are valid.
    @Published private(set) var isValidForm = false
    
    private var cancellables: Set<AnyCancellable> = []
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AddProjectViewModel.self)
    )
    
    init() {
        $projectName
            .receive(on: DispatchQueue.main)
            .map { [weak self] text in
                guard let self else { return false }
                let result = self.validateProjectName(text)
                switch result {
                case .success:
                    return true
                case .failure:
                    return false
                }
            }
            .assign(to: \.isValidForm, on: self)
            .store(in: &cancellables)
    }
}

extension AddProjectViewModel {
    // TODO: should i make this global if other fields (like tag input) need it?
    /// Checks that the project name is valid.
    /// - Parameter name: The name to validate.
    /// - Returns: A `Result` that is either a `Bool` if successful or a `ValidationError` otherwise.
    func validateProjectName(_ name: String) -> Result<Bool, ValidationError> {
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
