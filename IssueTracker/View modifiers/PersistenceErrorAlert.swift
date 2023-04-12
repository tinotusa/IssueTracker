//
//  PersistenceErrorAlert.swift
//  IssueTracker
//
//  Created by Tino on 12/4/2023.
//

import SwiftUI

struct PersistenceErrorAlert: ViewModifier {
    @Binding var didError: Bool
    @Binding var error: PersistenceError?
    
    func body(content: Content) -> some View {
        content
            .alert(
                "Save failed.",
                isPresented: $didError,
                presenting: $error
            ) { error in
                
            } message: { error in
                Text("Failed to save the changes made.")
            }
    }
}

extension View {
    func persistenceErrorAlert(isPresented didError: Binding<Bool>, presenting error: Binding<PersistenceError?>) -> some View {
        modifier(PersistenceErrorAlert(didError: didError, error: error))
    }
}
