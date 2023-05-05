//
//  ProminentTagView.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import SwiftUI

struct ProminentTagView: View {
    let tag: Tag
    var isSelected = false
    
    var body: some View {
        Text(tag.wrappedName)
            .foregroundColor(isSelected ? .tagTextSelected : .tagTextUnselected)
            .bodyStyle()
            .padding(.vertical, 2)
            .padding(.horizontal, 10)
            .background(isSelected ? tagColour : .gray)
            .cornerRadius(Constants.cornerRadius)
    }
    
    var tagColour: Color {
        guard let colour = Color(hex: tag.wrappedColour, opacity: tag.wrappedOpacity) else {
            return .blue
        }
        return colour
    }
    
    private enum Constants {
        static let cornerRadius = 5.0
    }
}

struct ProminentTagView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProminentTagView(tag: .preview)
            ProminentTagView(tag: .preview, isSelected: true)
        }
    }
}
