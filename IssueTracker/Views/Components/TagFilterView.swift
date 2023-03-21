//
//  TagFilterView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct TagFilterView: View {
    @State private var filterText = ""
    @Binding var selectedTags: Set<Tag>
    
    var body: some View {
        VStack(alignment: .leading) {
            CustomTextField("Search tags", text: $filterText)
            TagsView(filterText: filterText, selectedTags: $selectedTags)
        }
        .bodyStyle()
    }
}

struct TagsView: View {
    let filterText: String
    @Binding var selectedTags: Set<Tag>
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    init(filterText: String, selectedTags: Binding<Set<Tag>>) {
        _selectedTags = selectedTags
        self.filterText = filterText
        _allTags = FetchRequest(
            sortDescriptors: [.init(\.dateCreated, order: .reverse)],
            predicate: filterText.isEmpty ? nil : .init(format: "%K CONTAINS[cd] %@", "name", filterText)
        )
    }
    
    var body: some View {
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
    
    private func addTagToSelection(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    private func addNewTag(named name: String) {
        let tag = Tag(context: viewContext)
        tag.name = name
        tag.id = UUID()
        tag.dateCreated = Date()
        try? viewContext.save()
    }
}

struct TagFilterView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.tagsPreview.container.viewContext
    
    struct ContainerView: View {
        @State private var selectedTags: Set<Tag> = []
        
        var body: some View {
            TagFilterView(selectedTags: $selectedTags)
        }
    }
    
    static var previews: some View {
        ContainerView()
            .environment(\.managedObjectContext, viewContext)
    }
}
