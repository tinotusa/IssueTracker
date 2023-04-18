//
//  ErrorView.swift
//  IssueTracker
//
//  Created by Tino on 18/4/2023.
//

import SwiftUI

struct ErrorView: View {
    let errorWrapper: ErrorWrapper
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("An error has occurred")
                    .font(.title)
                Divider()
                Text(errorWrapper.error.localizedDescription)
                    .font(.headline)
                Text(errorWrapper.message)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.ultraThinMaterial)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
            }
        }
    }
}

private extension ErrorView {
    var cancelButton: some View {
        Button("Cancel", role: .cancel) {
            dismiss()
        }
    }
}


struct ErrorView_Previews: PreviewProvider {
    enum TestError: LocalizedError {
        case error
        
        var errorDescription: String? {
            switch self {
            case .error: return "Test error. error occurred."
            }
        }
    }
    
    static let errorWrapper = ErrorWrapper(error: TestError.error, message: "This is sample error.")
    
    static var previews: some View {
        ErrorView(errorWrapper: errorWrapper)
    }
}
