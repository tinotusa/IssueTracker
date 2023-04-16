//
//  SheetWithIndicator.swift
//  IssueTracker
//
//  Created by Tino on 16/4/2023.
//

import SwiftUI

struct SheetWithIndicator: ViewModifier {
    let presentationDetents: Set<PresentationDetent>
    func body(content: Content) -> some View {
        content
            .presentationDetents(presentationDetents)
            .presentationDragIndicator(.visible)
    }
}

extension View {
    func sheetWithIndicator(presentationDetents: Set<PresentationDetent> = [.large]) -> some View {
        modifier(SheetWithIndicator(presentationDetents: presentationDetents))
    }
}
