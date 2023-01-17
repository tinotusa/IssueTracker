//
//  AddProjectView.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct AddProjectView: View {
    @StateObject private var viewModel = AddProjectViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            TextField("Name", text: $viewModel.projectName)
            HStack {
                Button("Close") {
                    dismiss()
                }
                
                Button("Add project") {
                    viewModel.addProject()
                    dismiss()
                }
            }
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
