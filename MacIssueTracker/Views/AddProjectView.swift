//
//  AddProjectView.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI
import Combine

struct AddProjectView: View {
    @StateObject private var viewModel = AddProjectViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            TextField("Project name", text: $viewModel.projectName)
                .onReceive(Just(viewModel.projectName), perform: viewModel.filterName)
                .onSubmit {
                    viewModel.addProject()
                }
            HStack {
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                .help("Close this sheet")
                
                Button("Add project") {
                    viewModel.addProject()
                    dismiss()
                }
                .disabled(viewModel.addButtonDisabled)
                .help("Add new project")
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Add new project")
        .padding()
        .frame(minWidth: 300, minHeight: 300)
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    
    static var previews: some View {
        AddProjectView()
            .environment(\.managedObjectContext, viewContext)
    }
}
