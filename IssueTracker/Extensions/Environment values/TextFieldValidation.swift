//
//  TextFieldValidation.swift
//  IssueTracker
//
//  Created by Tino on 20/4/2023.
//

import SwiftUI

struct TextFieldValidation: EnvironmentKey {
    static var defaultValue: ((String) -> Result<Bool, ValidationError>)? = nil
}

extension EnvironmentValues {
    var textFieldValidation: ((String) -> Result<Bool, ValidationError>)? {
        get { self[TextFieldValidation.self] }
        set { self[TextFieldValidation.self] = newValue }
    }
}

extension View {
    func textFieldInputValidationHandler(_ handler: @escaping (String) -> Result<Bool, ValidationError>) -> some View {
        environment(\.textFieldValidation, handler)
    }
}
