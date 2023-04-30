//
//  IssueRowView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct IssueRowView: View {
    var issueProperties: IssueProperties
    @State private var isOpen = false
    let closeIssueAction: () -> Void
    
    var body: some View {
        HStack {
            Toggle("Issue status", isOn: $isOpen)
                .toggleStyle(.radioButton)
            VStack(alignment: .leading) {
                Text(issueProperties.name)
                    .font(.title3)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if !issueProperties.issueDescription.isEmpty {
                    Text(issueProperties.issueDescription)
                        .footerStyle()
                } else {
                    Text("Description: N/A")
                        .footerStyle()
                }
                
                if let tags = issueProperties.sortedTags {
                    if tags.isEmpty {
                        Text("No tags")
                            .footerStyle()
                    } else {
                        HStack {
                            Text("Tags: ")
                            ForEach(tags) { tag in
                                Text(tag.wrappedName)
                            }
                        }
                        .footerStyle()
                    }
                }
            }
        }
        .onChange(of: isOpen, perform: changeIssueStatus)
    }
}

private extension IssueRowView {
    func changeIssueStatus(isOpen: Bool) {
        closeIssueAction()
    }
}

struct IssueRowView_Previews: PreviewProvider {
    static var previews: some View {
        IssueRowView(issueProperties: .init(name: "testing", issueDescription: "some description", priority: .low, tags: [])) {
            
        }
    }
}
