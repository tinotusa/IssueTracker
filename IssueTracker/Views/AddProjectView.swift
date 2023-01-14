//
//  AddProjectView.swift
//  IssueTracker
//
//  Created by Tino on 28/12/2022.
//

import SwiftUI
import Combine

struct AddProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = AddProjectViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    LabeledInputField("Project name:") {
                        CustomTextField("Project name", text: $viewModel.projectName)
                            .onReceive(Just(viewModel.projectName), perform: viewModel.filterName)
                    }
                    
                    LabeledInputField("Start date:") {
                        DatePicker("Start date", selection: $viewModel.startDate, displayedComponents: [.date])
                            .labelsHidden()
                            .padding(.bottom)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                ProminentButton("Add project") {
                    viewModel.addProject()
                    dismiss()
                }
                .disabled(viewModel.addButtonDisabled)
            }
            .bodyStyle()
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
                        viewModel.addProject()
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
                 PersistenceController.projectsPreview.container.viewContext
            )
    }
}
