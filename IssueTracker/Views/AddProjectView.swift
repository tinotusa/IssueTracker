//
//  AddProjectView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI
import Combine

struct AddProjectView: View {
    @State private var projectName = ""
    @State private var dateStarted: Date = .now
    
    @StateObject private var viewModel = AddProjectViewModel()
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    LabeledInputField("Project name:") {
                        CustomTextField("Project name", text: $viewModel.projectName)
                            .onReceive(Just(viewModel.projectName), perform: viewModel.filterName)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add project") {
                    persistenceController.addProject(name: projectName, dateStarted: dateStarted)
                    dismiss()
                }
                .disabled(viewModel.addButtonDisabled)
            }
            .persistenceErrorAlert(isPresented: $persistenceController.showingError, presenting: $persistenceController.persistenceError)
            .padding()
            .background(Color.customBackground)
            .toolbarBackground(Color.customBackground)
            .navigationTitle("New project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add project") {
                        persistenceController.addProject(name: projectName, dateStarted: dateStarted)
                        dismiss()
                    }
                    .disabled(viewModel.addButtonDisabled)
                }
            }
        }
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView()
            .environment(
                \.managedObjectContext,
                 PersistenceController.preview.container.viewContext
            )
            .environmentObject(PersistenceController.preview)
    }
}
