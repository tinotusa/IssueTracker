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
            .background {
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(lineWidth: 1)
                    .opacity(0.4)
                    .foregroundColor(.black)
            }
    }
    
    private enum Constants {
        static let cornerRadius = 5.0
    }
}

struct ProminentTagView_Previews: PreviewProvider {
    static var previews: some View {
        ProminentTagView(title: "some title")
    }
}
