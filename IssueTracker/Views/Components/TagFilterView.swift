//
//  TagFilterView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct TagFilterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated_, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    private let filterText: String
    private let action: (Tag) -> Void
    
    init(filterText: String, action: @escaping (Tag) -> Void) {
        self.filterText = filterText
        self.action = action
        _allTags = FetchRequest(
            sortDescriptors: [.init(\.dateCreated_, order: .reverse)],
            predicate: filterText.isEmpty ? nil : .init(format: "%K CONTAINS[cd] %@", "name_", filterText)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
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
                    TagButton(tag.name) {
                        action(tag)
                    }
                }
            }
        }
        .bodyStyle()
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
    
    static var previews: some View {
        TagFilterView(filterText: "") { _ in
            // do nothing
        }
        .environment(\.managedObjectContext, viewContext)
    }
}
