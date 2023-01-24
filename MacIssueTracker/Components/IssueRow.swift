//
//  IssueRow.swift
//  MacIssueTracker
//
//  Created by Tino on 24/1/2023.
//

import SwiftUI

struct IssueRow: View {
    let issue: Issue
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text(issue.name)
                    .lineLimit(2)
                Spacer()
                Text(issue.dateCreated.formatted(date: .numeric, time: .omitted))
                    .secondaryFootnote()
            }
            Group {
                if issue.issueDescription.isEmpty {
                    Text("No description")
                } else {
                    Text(issue.issueDescription)
                        .lineLimit(2)
                }
            }
            .secondaryFootnote()
        }
    }
}

struct IssueRow_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    
    static var previews: some View {
        IssueRow(issue: .init(name: "Test issue name", issueDescription: "", priority: .low, tags: [], context: viewContext))
    }
}
