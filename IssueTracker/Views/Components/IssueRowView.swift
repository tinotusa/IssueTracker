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
            Text(issue.name)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if !issue.issueDescription.isEmpty {
                Text(issue.issueDescription)
                    .footerStyle()
            } else {
                Text("Description: N/A")
                    .footerStyle()
            }
            
            if let tags = issue.tags {
                if tags.set.isEmpty {
                    Text("No tags")
                        .footerStyle()
                } else {
                    HStack {
                        Text("Tags: ")
                        ForEach(tags.array as? [Tag] ?? []) { tag in
                            Text(tag.name)
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
