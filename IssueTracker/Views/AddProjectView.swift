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
        VStack {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    Text(viewModel.title)
                        .titleStyle()
                        .padding(.bottom)
                    
                    Text(viewModel.projectNamePrompt)
                    CustomTextField(viewModel.projectNamePlaceholder, text: $viewModel.projectName)
                        .onReceive(Just(viewModel.projectName), perform: viewModel.filterName)
                    
                    Text(viewModel.datePrompt)
                    DatePicker("Start date", selection: $viewModel.startDate, displayedComponents: [.date])
                        .labelsHidden()
                        .padding(.bottom)
                    
                    ProminentButton(viewModel.addButtonTitle) {
                        viewModel.addProject()
                    }
                    .disabled(viewModel.addButtonDisabled)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .bodyStyle()
        .padding()
        .background(Color.customBackground)
        .presentationDragIndicator(.visible)
    }
}

private extension AddProjectView {
    var header: some View {
        HStack {
            PlainButton("Close") {
                dismiss()
            }
            Spacer()
            PlainButton("Add project") {
                
            }
            .disabled(viewModel.addButtonDisabled)
        }
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView()
    }
}
