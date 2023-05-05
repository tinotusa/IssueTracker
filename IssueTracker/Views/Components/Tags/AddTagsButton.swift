//
//  AddTagsButton.swift
//  IssueTracker
//
//  Created by Tino on 5/5/2023.
//

import SwiftUI

struct AddTagsButton: View {
    let action: () -> Void
    let tagCount: Int
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: "number")
                    .padding(4)
                    .background(.blue.gradient)
                    .foregroundColor(.white)
                    .cornerRadius(5)
     
                Text("Tags")
                
                Spacer()
                
                Text(tagCountText)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: Computed variables
private extension AddTagsButton {
    var tagCountText: LocalizedStringKey {
        tagCount == 0 ? "No tags" : "^[\(tagCount) tag](inflect: true)"
    }
}


struct AddTagsButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AddTagsButton(action: {}, tagCount: 0)
            AddTagsButton(action: {}, tagCount: 1)
            AddTagsButton(action: {}, tagCount: 2)
        }
    }
}
