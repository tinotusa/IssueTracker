//
//  IssueRowView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct IssueRowView: View {
    let issue: Issue
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(issue.wrappedName)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if !issue.wrappedIssueDescription.isEmpty {
                Text(issue.wrappedIssueDescription)
                    .footerStyle()
            } else {
                Text("Description: N/A")
                    .footerStyle()
            }
            
            if let tags = issue.tags {
                if tags.allObjects.isEmpty {
                    Text("No tags")
                        .footerStyle()
                } else {
                    HStack {
                        Text("Tags: ")
                        ForEach(tags.allObjects as? [Tag] ?? []) { tag in
                            Text(tag.wrappedName)
                        }
                    }
                    .footerStyle()
                }
            }
        }
        .bodyStyle()
    }
}

struct IssueRowView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.issuesPreview.container.viewContext
    static var previews: some View {
        IssueRowView(issue: .init(name: "test issue", issueDescription: "", priority: .low, tags: [], context: viewContext))
    }
}
