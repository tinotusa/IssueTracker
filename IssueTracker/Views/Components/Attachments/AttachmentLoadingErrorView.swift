//
//  AttachmentLoadingErrorView.swift
//  IssueTracker
//
//  Created by Tino on 3/5/2023.
//

import SwiftUI

struct AttachmentLoadingErrorView: View {
    let errorType: ErrorType
    
    var body: some View {
        VStack {
            Image(systemName: errorType.systemName)
                .font(.title2)
            Text(errorType.message)
        }
        .foregroundColor(.red)
    }
    
    enum ErrorType {
        case error
        case notFound
        
        var message: LocalizedStringKey {
            switch self {
            case .error: return "Error."
            case .notFound: return "Not found."
            }
        }
        
        var systemName: String {
            switch self {
            case .notFound: return SFSymbol.exclamationmarkOctagonFill
            case .error: return SFSymbol.xmarkOctagonFill
            }
        }
    }
}

struct AttachmentLoadingErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentLoadingErrorView(errorType: .error)
    }
}
