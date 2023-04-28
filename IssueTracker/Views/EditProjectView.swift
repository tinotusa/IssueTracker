//
//  EditProjectView.swift
//  IssueTracker
//
//  Created by Tino on 29/12/2022.
//

import SwiftUI

struct EditProjectView: View {
    @Binding var projectProperties: ProjectProperties
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Group {
                    Section("Project name") {
                        TextField("Project name", text: $projectProperties.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    Section("Start date") {
                        DatePicker(
                            "Project start date",
                            selection: $projectProperties.startDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                    
                    ProminentButton("Save changes", action: dismiss.callAsFunction)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
            }
            .listStyle(.plain)
            .navigationTitle("Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Done", action: dismiss.callAsFunction)
                }
            }
            .background(Color.customBackground)
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EditProjectView(projectProperties: .constant(.init(name: "testing", startDate: .now)))
        }
    }
}
