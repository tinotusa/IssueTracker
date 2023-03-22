//
//  TagSelectionView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI
import CoreData

struct TagSelectionView: View {
    @State private var filterText = ""
    @Binding private(set) var selectedTags: Set<Tag>
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    init(selectedTags: Binding<Set<Tag>>) {
        _selectedTags = selectedTags
        self.filterText = filterText
        _allTags = FetchRequest(
            sortDescriptors: [.init(\.dateCreated, order: .reverse)],
            predicate: filterText.isEmpty ? nil : .init(format: "name CONTAINS[cd] %@", filterText)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Search tags", text: $filterText)
                .textFieldStyle(.roundedBorder)
            VStack {
                if allTags.isEmpty && filterText.isEmpty {
                    Text("No tags.\nType a new tag.")
                        .foregroundColor(.customSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if allTags.isEmpty {
                    PlainButton("Add new tag") {
                        addNewTag(named: filterText)
                    }
                }
                // TODO: add custom layout here
                LazyVGrid(columns: [.init(.adaptive(minimum: 100))]) {
                    ForEach(allTags) { tag in
                        Button {
                            addTagToSelection(tag)
                        } label: {
                            ProminentTagView(title: tag.wrappedName, isSelected: selectedTags.contains(tag))
                        }
                    }
                }
            }
        }
        .bodyStyle()
        .onChange(of: filterText) { text in
            let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
            allTags.nsPredicate = text.isEmpty ? nil : predicate
        }
    }
}

private extension TagSelectionView {
    func addTagToSelection(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    func addNewTag(named name: String) {
        let tag = Tag(context: viewContext)
        tag.name = name
        tag.id = UUID()
        tag.dateCreated = Date()
        try? viewContext.save()
    }
}

struct TagSelectionView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.tagsPreview.container.viewContext
    
    struct ContainerView: View {
        @State private var selectedTags: Set<Tag> = []
        
        var body: some View {
            TagSelectionView(selectedTags: $selectedTags)
        }
    }
    
    static var previews: some View {
        ContainerView()
            .environment(\.managedObjectContext, viewContext)
    }
}
