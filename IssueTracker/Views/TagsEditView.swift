//
//  TagsEditView.swift
//  IssueTracker
//
//  Created by Tino on 2/1/2023.
//

import SwiftUI

struct TagsEditView: View {
    @State private var showingDeleteAllConfirmation = false
    @State private var selectedTag: Tag?
    @State private var errorWrapper: ErrorWrapper?
    
    @EnvironmentObject private var persistenceController: PersistenceController
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var tags: FetchedResults<Tag>
    
    var body: some View {
        NavigationStack {
            List {
                if tags.isEmpty {
                    Text("No tags to edit.\n🏷")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.customBackground)
                } else {
                    ForEach(tags) { tag in
                        Button {
                            selectedTag = tag
                        } label: {
                            VStack(alignment: .leading) {
                                Text(tag.wrappedName)
                                Text("Created \(tag.wrappedDateCreated.formatted(date: .abbreviated,  time: .omitted))")
                                    .footerStyle()
                            }
                        }
                        .listRowBackground(Color.customBackground)
                    }
                    .onDelete(perform: deleteTag)
                }
            }
            .background(Color.customBackground)
            .navigationTitle("Edit tags")
            .listStyle(.plain)
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(role: .destructive) {
                        showingDeleteAllConfirmation = true
                    } label: {
                        Text("Delete all")
                    }
                    .disabled(tags.isEmpty)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.red)
                }
            }
        }
        .confirmationDialog("Delete all tags", isPresented: $showingDeleteAllConfirmation) {
            Button("Delete all", role: .destructive) {
                deleteAllTags()
            }
        } message: {
            Text("Are you sure you want to delete all tags?")
        }
        .sheet(item: $selectedTag) { tag in
            EditTagView(tag: tag)
        }
        .sheet(item: $errorWrapper) { error in
            ErrorView(errorWrapper: error)
        }
    }
}

extension TagsEditView {
    /// Deletes a tag based on the index.
    /// - Parameter offsets: The offset(index) of the tag.
    func deleteTag(offsets indexSet: IndexSet) {
        Task {
            do {
                for index in indexSet {
                    try await persistenceController.deleteObject(tags[index])
                }
            } catch {
                errorWrapper = .init(error: error, message: "Failed to delete tag. Try again.")
            }
        }
    }
    
    /// Deletes all the tags.
    func deleteAllTags() {
        Task {
            do {
                let tags = tags.map { $0 }
                try await persistenceController.deleteObjects(tags)
            } catch {
                errorWrapper = .init(error: error, message: "Failed to delete all tags.")
            }
        }
    }
}
    

struct TagsEditView_Previews: PreviewProvider {    
    static var previews: some View {
        TagsEditView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(PersistenceController.preview)
    }
}
