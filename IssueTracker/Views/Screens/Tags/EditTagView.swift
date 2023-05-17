//
//  EditTagView.swift
//  IssueTracker
//
//  Created by Tino on 14/1/2023.
//

import SwiftUI

struct EditTagView: View {
    @ObservedObject private(set) var tag: Tag
    @State private var name: String = ""
    @State private var showingCancelDialog = false
    @State private var errorWrapper: ErrorWrapper?
    
    @EnvironmentObject private var persistenceController: PersistenceController
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationStack {
            List {
                Section("Tag name") {
                    TextField("Tag name", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.customBackground)
            }
            .listStyle(.plain)
            .listRowBackground(Color.customBackground)
            .navigationTitle("Edit tag")
            .onAppear {
                name = tag.wrappedName
            }
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
        .background(Color.customBackground)
        .confirmationDialog("Discard changes", isPresented: $showingCancelDialog) {
            Button("Discard changes", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Are you sure you want to discard the changes you've made?")
        }
        .sheet(item: $errorWrapper) { error in
            ErrorView(errorWrapper: error)
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
        Task {
            tag.name = name
            do {
                try await persistenceController.save()
            } catch {
                errorWrapper = .init(error: error, message: "Failed to save the tag edit.")
            }
        }
    }
}

struct EditTagView_Previews: PreviewProvider {
    struct ContainerView: View {
        @FetchRequest(sortDescriptors: [])
        private var tags: FetchedResults<Tag>
        
        var body: some View {
            if let tag = tags.first {
                EditTagView(tag: tag)
            }
        }
    }
    
    static var viewContext = {
        let context = PersistenceController.preview.container.viewContext
        _ = Tag.makePreviews(count: 3)
        return context
    }()
    
    static var previews: some View {
        ContainerView()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PersistenceController.preview)
    }
}
