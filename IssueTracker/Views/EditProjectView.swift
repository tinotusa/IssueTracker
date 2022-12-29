//
//  EditProjectView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI

struct EditProjectView: View {
    @ObservedObject var project: Project
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var startDate = Date()
    @State private var showingHasChangesConfirmationDialog = false
    
    init(project: Project) {
        self.project = project
        _name = State(wrappedValue: project.name)
        _startDate = State(wrappedValue: project.startDate)
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
        if self.name != project.name || self.startDate != project.startDate {
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
struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: .example(context: PersistenceController.empty.container.viewContext))
    }
}
