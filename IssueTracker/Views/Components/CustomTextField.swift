//
//  CustomTextField.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

struct CustomTextField: View {
    private let title: LocalizedStringKey
    @Binding var text: String
    @State private var isValid = false
    @State private var errorMessage: String?

    @Environment(\.mandatoryFormField) private var isMandatory
    @Environment(\.textFieldValidation) private var textFieldValidation    

    init(_ title: LocalizedStringKey, text: Binding<String>) {
        self.title = title
        _text = text
    }

    @FocusState private var isFocused
    @State private var hasAlreadySeenField = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if let errorMessage, (hasAlreadySeenField || isFocused), !isValid {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            HStack {
                TextField(title, text: $text)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                if textIsEmpty && isMandatory {
                    Text("*")
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            validate()
        }
        .onChange(of: text) { _ in
            validate()
        }
        .onChange(of: isFocused) { _ in
            if hasAlreadySeenField { return }
            hasAlreadySeenField = true
        }
    }
}

private extension CustomTextField {
    var textIsEmpty: Bool {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty
    }

    func validate() {
        guard let textFieldValidation else { return }
        let result = textFieldValidation(text)
        switch result {
        case .success:
            withAnimation {
                isValid = true
            }
        case .failure(let error):
            isValid = false
            errorMessage = error.localizedDescription
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    struct ContainerView: View {
        @State private var text = ""
        
        var body: some View {
            CustomTextField("placeholder", text: $text)
                .isMandatoryFormField(true)
                .textFieldInputValidationHandler { text in
                    let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                    if text.isEmpty {
                        return .failure(ValidationError.invalidInput(message: "Empty text"))
                    }
                    return .success(true)
                }
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}
