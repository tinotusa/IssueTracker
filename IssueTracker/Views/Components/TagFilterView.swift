//
//  TagFilterView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI

struct TagFilterView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    let filterText: String
    let action: (Tag) -> Void
    
    init(filterText: String, action: @escaping (Tag) -> Void) {
        self.filterText = filterText
        self.action = action
        _allTags = FetchRequest(
            sortDescriptors: [.init(\.dateCreated, order: .reverse)],
            predicate: filterText.isEmpty ? nil : .init(format: "%K CONTAINS[cd] %@", "name", filterText)
        )
    }
    
    var body: some View {
        // TODO: add custom layout here
        LazyVGrid(columns: [.init(.adaptive(minimum: 100))]) {
            if allTags.isEmpty {
                PlainButton("Add new tag") {
                    addNewTag(named: filterText)
                }
            }
            ForEach(allTags) { tag in
                TagButton(tag.name ?? "Not set") {
                    action(tag)
                }
            }
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


struct TagFilterView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.shared.container.viewContext
    
    static var previews: some View {
        TagFilterView(filterText: "") { _ in
            // do nothing
        }
        .environment(\.managedObjectContext, viewContext)
    }
}
