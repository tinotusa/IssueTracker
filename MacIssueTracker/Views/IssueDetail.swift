//
//  IssueDetail.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct IssueDetail: View {
    @ObservedObject var issue: Issue
    
    var body: some View {
        VStack {
            Text(issue.name)
            Text(issue.issueDescription)
            Text(issue.priority.title)
            Text("Started: \(issue.dateCreated.formatted())")
        }
    }
}

struct IssueDetail_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    static var issue = Issue(name: "some issue", issueDescription: "", priority: .low, tags: [], context: viewContext)
    static var previews: some View {
        IssueDetail(issue: issue)
    }
}
