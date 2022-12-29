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

    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    var projects: FetchedResults<Project>
    
    var body: some View {
        NavigationStack {
            VStack {
                header
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Select project")
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
                EditView(project: project)
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }
}

struct EditView: View {
    @ObservedObject var project: Project
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var startDate = Date()
    @State private var showingHasChangesConfirmationDialog = false
    
    init(project: Project) {
        self.project = project
        _name = State(wrappedValue: project.name ?? "Name not set")
        _startDate = State(wrappedValue: project.startDate ?? Date())
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                PlainButton("Cancel", action: cancel)
                Spacer()
                PlainButton("Save", action: save)
            }
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Editing Project")
                        .titleStyle()
                    Text("Project name:")
                    CustomTextField("Project name", text: $name)
                    
                    Text("Project start date:")
                    DatePicker("Project start date", selection: $startDate, displayedComponents: [.date])
                        .padding(.bottom)
                    ProminentButton("Save changes", action: save)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .bodyStyle()
        .confirmationDialog("Changes not saved.", isPresented: $showingHasChangesConfirmationDialog) {
            Button("Dont save changes", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You have changes that haven't been saved.")
        }
    }
    
    func cancel() {
        guard let projectName = project.name else {
            return
        }
        guard let startDate = project.startDate else {
            return
        }
        if self.name != projectName || self.startDate != startDate {
            showingHasChangesConfirmationDialog = true
        } else {
            dismiss()
        }
    }
    
    func save() {
        project.name = name
        project.startDate = startDate
        try? viewContext.save()
        dismiss()
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
struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectsView()
            .environment(
                \.managedObjectContext,
                 PersistenceController.projectsPreview.container.viewContext
            )
        
    }
}
