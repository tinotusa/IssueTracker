//
//  EditTagView.swift
//  IssueTracker
//
//  Created by Tino on 14/1/2023.
//

import SwiftUI

struct EditTagView: View {
    @ObservedObject var tag: Tag
    @State private var name: String = ""
    @State private var showingCancelDialog = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            VStack {
                LabeledInputField("Tag name:") {
                    CustomTextField("Tag name", text: $name)
                }
                ProminentButton("Save", action: save)
                    .disabled(!hasChanges)
            }
            .navigationTitle("Edit tag")
            .onAppear {
                name = tag.name
            }
            .padding()
            .frame(maxHeight: .infinity)
            .background(Color.customBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        if name != tag.name {
                            showingCancelDialog = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(!hasChanges)
                }
            }
        }
        .bodyStyle()
        .confirmationDialog("Discard changes", isPresented: $showingCancelDialog) {
            Button("Discard changes", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure you want to discard the changes you've made?")
        }
    }
}

private extension EditTagView {
    /// A boolean value that indicates whether or not the tag has been changed.
    var hasChanges: Bool {
        name != tag.name
    }
    
    /// Saves the changes made.
    func save() {
        tag.name = name
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
    }
}

struct EditTagView_Previews: PreviewProvider {
    static var previews: some View {
        EditTagView(tag: .init(name: "Test tag", context: PersistenceController.empty.container.viewContext))
    }
}
