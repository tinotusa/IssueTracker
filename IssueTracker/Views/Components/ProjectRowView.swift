//
//  ProjectRowView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI

struct ProjectRowView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(project.wrappedName)
                .headerStyle()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Group {
                if let latestIssue = project.latestIssue {
                    Text(latestIssue.wrappedName)
                    if let date = latestIssue.dateCreated {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                    }
                } else {
                    Text("No issues.")
                }
            }
            .footerStyle()

            Divider()
        }
        .bodyStyle()
    }
}

struct ProjectRowView_Previews: PreviewProvider {    
    static var previews: some View {
        ProjectRowView(project: .preview)
    }
}
