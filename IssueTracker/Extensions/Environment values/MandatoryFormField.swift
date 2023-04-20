//
//  MandatoryFormField.swift
//  IssueTracker
//
//  Created by Tino on 20/4/2023.
//

import SwiftUI

struct MandatoryFormField: EnvironmentKey {
    static var defaultValue = false
}

extension EnvironmentValues {
    var mandatoryFormField: Bool {
        get { self[MandatoryFormField.self] }
        set { self[MandatoryFormField.self] = newValue }
    }
}

extension View {
    func isMandatoryFormField(_ isMandatory: Bool) -> some View {
        environment(\.mandatoryFormField, isMandatory)
    }
}
