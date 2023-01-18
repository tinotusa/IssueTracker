//
//  TagFilterView.swift
//  MacIssueTracker
//
//  Created by Tino on 18/1/2023.
//

import SwiftUI

/// Displays a VStack of tags.
struct TagFilterView<Content: View>: View {
    private let content: (Tag) -> Content
    private var searchText: String
    
    @State private var tagColour: Color = .blue
    
    @FetchRequest(sortDescriptors: [])
    private var allTags: FetchedResults<Tag>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    init(searchText: String, @ViewBuilder content: @escaping (Tag) -> Content) {
        self.content = content
        self.searchText = searchText
        _allTags = FetchRequest<Tag>(
            sortDescriptors: [.init(\.dateCreated_, order: .forward)],
            predicate: searchText.isEmpty ? nil : .init(format: "%K CONTAINS[cd] %@", "name_", searchText)
        )
    }
    
    var body: some View {
        Form {
            if !searchText.isEmpty && allTags.isEmpty {
                Button("Create new tag \"\(searchText)\"") {
                    _ = Tag(name: searchText, context: viewContext)
                    try? viewContext.save()
                }
                ColorPicker(selection: $tagColour) {
                    Text("Tag colour")
                }
            }
            ForEach(allTags) { tag in
                content(tag)
            }
        }
    }
}

struct TagFilterView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.tagsPreview.container.viewContext
    
    static var previews: some View {
        TagFilterView(searchText: "") { tag in
            Button(tag.name) {
                
            }
        }
        .environment(\.managedObjectContext, viewContext)
    }
}
