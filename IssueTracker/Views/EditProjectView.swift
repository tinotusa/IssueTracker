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
                    .disabled(!projectHasChanges)
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
                        .disabled(!projectHasChanges)
                }
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .bodyStyle()
        .background(Color.customBackground)
        .confirmationDialog("Changes not saved.", isPresented: $showingHasChangesConfirmationDialog) {
            Button("Dont save changes", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("You have changes that haven't been saved.")
        }
    }
    
    func cancel() {
        if projectHasChanges {
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
    
    var projectHasChanges: Bool {
        let dateOrder = Calendar.current.compare(self.startDate, to: project.startDate, toGranularity: .day)
        return self.name != project.name || dateOrder != .orderedSame
    }
}
struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(project: .example(context: PersistenceController.empty.container.viewContext))
    }
}
