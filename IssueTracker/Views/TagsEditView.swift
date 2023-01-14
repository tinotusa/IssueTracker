//
//  TagsEditView.swift
//  IssueTracker
//
//  Created by Tino on 2/1/2023.
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
                    Button("Save", action: save)
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


    var hasChanges: Bool {
        name != tag.name
    }

    func save() {
        tag.name = name
        do {
            try viewContext.save()
            dismiss()
        } catch {
            viewContext.rollback()
        }
    }
}

struct TagsEditView: View {
    @State private var showingDeleteAllConfirmation = false
    @State private var selectedTag: Tag?
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: [])
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
                                Text(tag.name)
                                Text("Created \(tag.dateCreated.formatted(date: .abbreviated,  time: .omitted))")
                                    .footerStyle()
                            }
                        }
                        .listRowBackground(Color.customBackground)
                    }
                    .onDelete(perform: deleteTag)
                }
            }
            .bodyStyle()
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
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

extension TagsEditView {
    /// Deletes a tag based on the index.
    /// - Parameter offsets: The offset(index) of the tag.
    func deleteTag(_ offsets: IndexSet) {
        offsets.map { tags[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
    }
    
    /// Deletes all the tags.
    func deleteAllTags() {
        tags.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            viewContext.rollback()
        }
    }
}
    

struct TagsEditView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.tagsPreview.container.viewContext
    
    static var previews: some View {
        TagsEditView()
            .environment(\.managedObjectContext, viewContext)
    }
}
