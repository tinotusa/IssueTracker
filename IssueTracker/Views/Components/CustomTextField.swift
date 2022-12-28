//
//  CustomTextField.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

struct CustomTextField: View {
    private let placeholder: LocalizedStringKey
    @Binding var text: String
    
    init(_ placeholder: LocalizedStringKey, text: Binding<String>) {
        self.placeholder = placeholder
        _text = text
    }
    
    var body: some View {
        VStack {
            TextField(placeholder, text: $text)
            Rectangle()
                .frame(height: 1)
                .opacity(0.2)
        }
        .bodyStyle()
    }
}

struct CustomTextField_Previews: PreviewProvider {
    struct ContainerView: View {
        @State private var text = ""
        
        var body: some View {
            CustomTextField("placeholder", text: $text)
        }
    }
    static var previews: some View {
        ContainerView()
    }
}
