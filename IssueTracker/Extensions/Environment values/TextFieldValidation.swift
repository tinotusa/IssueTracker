//
//  TextFieldValidation.swift
//  IssueTracker
//
//  Created by Tino on 20/4/2023.
//

import SwiftUI

struct TextFieldValidation: EnvironmentKey {
    static var defaultValue: ((String) -> Result<Void, ValidationError>)? = nil
}

extension TextFieldValidation {
    enum ValidationError: LocalizedError {
        case emptyText
        case invalidInput(message: String)
        
        var errorDescription: String? {
            switch self {
            case .emptyText: return "The text field is empty."
            case .invalidInput(let message): return message
            }
        }
    }
}

extension EnvironmentValues {
    var textFieldValidation: ((String) -> Result<Void, TextFieldValidation.ValidationError>)? {
        get { self[TextFieldValidation.self] }
        set { self[TextFieldValidation.self] = newValue }
    }
}

extension View {
    func textFieldInputValidationHandler(_ handler: @escaping (String) -> Result<Void, TextFieldValidation.ValidationError>) -> some View {
        environment(\.textFieldValidation, handler)
    }
}
