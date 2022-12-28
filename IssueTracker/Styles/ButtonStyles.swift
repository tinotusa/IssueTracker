//
//  ButtonStyles.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

struct ButtonStyles: View {
    var body: some View {
        VStack {
            ProminentButton("Press me") {
                
            }
            ProminentButton("Disabled") {
                
            }
            .disabled(true)
            PlainButton("testing") {
                
            }
            PlainButton("testing") {
                
            }
            .disabled(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.customBackground)
    }
}

struct PlainButton: View {
    @Environment(\.isEnabled) private var isEnabled
    private let title: LocalizedStringKey
    private let action: () -> Void
    
    init(_ title: LocalizedStringKey, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(title) {
            action()
        }
        .foregroundColor(!isEnabled ? .buttonLabelDisabled : .buttonLabel)
    }
}

struct ProminentButton: View {
    @Environment(\.isEnabled) private var isEnabled
    private let title: LocalizedStringKey
    private let action: () -> Void
    
    init(_ title: LocalizedStringKey, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .frame(minWidth: 2)
                .foregroundColor(!isEnabled ? .buttonTextDisabled : .buttonText)
                .buttonTextStyle()
                .padding()
                .background(!isEnabled ? Color.buttonDisabled : Color.buttonBackground)
                .cornerRadius(10)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
        }
    }
}

struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        ButtonStyles()
    }
}
