//
//  LabeledInputField.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI


struct LabeledInputField<Content: View>: View {
    let label: LocalizedStringKey
    let content: () -> Content
    
    init(_ label: LocalizedStringKey, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
            content()
        }
        .bodyStyle()
    }
}

struct LabeledInputField_Previews: PreviewProvider {
    static var previews: some View {
        LabeledInputField("Preview label") {
            Text("hello world")
        }
    }
}
