//
//  TagSelectionView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI
import CoreData

struct TagSelectionView: View {
    @State private var searchText = ""
    @State private var errorWrapper: ErrorWrapper?
    @State private var draftTags: Set<Tag> = []
    @State private var tagColour = Color.blue
    @Binding private(set) var selectedTags: Set<Tag>
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var persistenceController: PersistenceController
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    init(selection selectedTags: Binding<Set<Tag>>) {
        _selectedTags = selectedTags
        draftTags = selectedTags.wrappedValue
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                WrappingHStack {
                    ForEach(allTags) { tag in
                        Button {
                            addTagToSelection(tag)
                        } label: {
                            ProminentTagView(tag: tag, isSelected: draftTags.contains(where: { $0.wrappedName == tag.wrappedName }))
                        }
                        .buttonStyle(.borderless)
                        .accessibilityIdentifier(tag.wrappedName)
                    }
                }
                
                TextField("Add new tag", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addNewTag)
                    .accessibilityIdentifier("tagInputField")
                ColorPicker(selection: $tagColour) {
                    Text("Tag colour")
                }
                .accessibilityIdentifier("colourPicker")
            }
            .accessibilityElement(children: .contain)
            .navigationTitle("Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                        .accessibilityIdentifier("TagSelectionView-cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: saveTags)
                        .accessibilityIdentifier("TagSelectionView-doneButton")
                }
            }
            .onAppear {
                draftTags = selectedTags
            }
        }
    }
}

// MARK: - Views
private extension TagSelectionView {
    func addNewTag() {
        defer { searchText = "" }
        let searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchText.isEmpty { return }
        if draftTags.contains(where: { $0.wrappedName == searchText }) {
            return
        }
        let tag = Tag(context: viewContext)
        tag.name = searchText
        tag.id = UUID()
        tag.dateCreated = .now
        tag.colour = tagColour.hexValue
        tag.opacity = tagColour.opacityValue
        
        addTagToSelection(tag)
    }
    
    func addTagToSelection(_ tag: Tag) {
        if draftTags.contains(tag) {
            draftTags.remove(tag)
        } else {
            draftTags.insert(tag)
        }
    }
    
    func saveTags() {
        selectedTags = draftTags
        dismiss()
    }
}

struct TagSelectionView_Previews: PreviewProvider {
    static var viewContext = {
        let viewContext = PersistenceController.preview.container.viewContext
        let tag = Tag.makePreviews(count: 1)
        return viewContext
    }()
    
    struct ContainerView: View {
        @State private var selectedTags: Set<Tag> = []
        
        var body: some View {
            TagSelectionView(selection: $selectedTags)
        }
    }
    
    static var previews: some View {
        ContainerView()
            .environment(\.managedObjectContext, viewContext)
            .environmentObject(PersistenceController.shared)
    }
}
