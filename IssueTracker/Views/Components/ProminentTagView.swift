//
//  ProminentTagView.swift
//  IssueTracker
//
//  Created by Tino on 31/12/2022.
//

import SwiftUI

struct ProminentTagView: View {
    let title: String
    var isSelected = false
    
    var body: some View {
        Text(title)
            .foregroundColor(isSelected ? .tagTextSelected : .tagTextUnselected)
            .bodyStyle()
            .padding(.vertical, 2)
            .padding(.horizontal, 10)
            .background(isSelected ? Color.tagSelected : Color.tagUnselected)
            .cornerRadius(Constants.cornerRadius)
    }
    
    private enum Constants {
        static let cornerRadius = 5.0
    }
}

struct ProminentTagView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProminentTagView(title: "some title")
            ProminentTagView(title: "some title", isSelected: true)
        }
    }
}
