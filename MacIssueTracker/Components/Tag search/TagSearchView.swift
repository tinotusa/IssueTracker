//
//  TagSearchView.swift
//  MacIssueTracker
//
//  Created by Tino on 18/1/2023.
//

import SwiftUI

/// Displays a text field and a list of tags.
struct TagSearchView: View {
    @Binding var selectedTags: Set<Tag>
    @State private var searchText = ""
    
    var body: some View {
        Form {
            TextField("Search for a tag", text: $searchText)
            
            TagFilterView(searchText: searchText) { tag in
                Button {
                    if tagIsSelected(tag) {
                        selectedTags.remove(tag)
                    } else {
                        selectedTags.insert(tag)
                    }
                } label: {
                    Text(tag.name)
                }
            }
        }
    }
}

private extension TagSearchView {
    /// Returns true if the given tag is already in the set of selected tags.
    /// - Parameter tag: The tag to check.
    /// - Returns: `true` if selectedTags already has the tag; `false` otherwise.
    func tagIsSelected(_ tag: Tag) -> Bool {
        selectedTags.contains(tag)
    }
}

struct TagSearchView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.tagsPreview.container.viewContext
    static var previews: some View {
        TagSearchView(selectedTags: .constant([]))
            .environment(\.managedObjectContext, viewContext)
    }
}
