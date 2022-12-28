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
            Text(project.name ?? "no name")
                .headerStyle()
            Group {
                if let latestIssue = project.latestIssue {
                    Text(latestIssue.name ?? "no name")
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
    static let viewContext = PersistenceController.shared.container.viewContext
    static let project = {
        let project = Project(context: viewContext)
        project.name = "preview project"
        project.id = UUID()
        project.startDate = .now
        project.dateCreated = .now
        
        return project
    }()
    
    static var previews: some View {
        ProjectRowView(project: project)
    }
}
