//
//  TagView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct TagView: View {
    let tag: Tag
    
    var body: some View {
        Text(tag.wrappedName)
            .font(.system(size: 16))
            .fontWeight(.light)
            .foregroundColor(.buttonText)
            .padding(.vertical, 2)
            .padding(.horizontal)
            .background(Color.tag)
            .cornerRadius(10)
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        TagView(tag: .preview)
    }
}
