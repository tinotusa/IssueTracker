//
//  View+secondaryFootnote.swift
//  MacIssueTracker
//
//  Created by Tino on 24/1/2023.
//

import SwiftUI

/// Adds footnote font and secondary foreground colour to a view.
struct SecondaryFootnote: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

extension View {
    /// A view that has the footnote font and secondary foreground colour.
    func secondaryFootnote() -> some View {
        modifier(SecondaryFootnote())
    }
}
