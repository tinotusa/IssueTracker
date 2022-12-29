//
//  EditProjectsView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI
import CoreData

struct EditProjectsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(sortDescriptors: [.init(\.dateCreated_, order: .reverse)])
    var projects: FetchedResults<Project>
    
    var body: some View {
        NavigationStack {
            VStack {
                header
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Edit project")
                            .titleStyle()
                            .padding(.bottom)
                        
                        ForEach(projects) { project in
                            NavigationLink(value: project) {
                                ProjectRowView(project: project)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .bodyStyle()
            .background(Color.customBackground)
            .navigationDestination(for: Project.self) { project in
                EditProjectView(project: project)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

private extension EditProjectsView {
    var header: some View {
        HStack {
            Spacer()
            PlainButton("Close") {
                dismiss()
            }
        }
    }
}

struct EditProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectsView()
            .environment(
                \.managedObjectContext,
                 PersistenceController.projectsPreview.container.viewContext
            )
        
    }
}
