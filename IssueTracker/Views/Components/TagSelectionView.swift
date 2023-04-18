//
//  TagSelectionView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI
import CoreData

struct TagSelectionView: View {
    @State private var tagName = ""
    @State private var errorWrapper: ErrorWrapper?
    @Binding private(set) var selectedTags: Set<Tag>
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var persistenceController: PersistenceController
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .reverse)])
    private var allTags: FetchedResults<Tag>
    
    init(selection selectedTags: Binding<Set<Tag>>) {
        _selectedTags = selectedTags
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Search tags", text: $tagName)
                .textFieldStyle(.roundedBorder)
            
            if allTags.isEmpty && tagName.isEmpty {
                Text("No tags.\nType a new tag.")
                    .foregroundColor(.customSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if allTags.isEmpty {
                PlainButton("Add \"\(tagName)\"") {
                    Task {
                        do {
                            try await persistenceController.addTag(named: tagName)
                        } catch {
                            errorWrapper = ErrorWrapper(error: error, message: "Failed to add new tag.")
                        }
                    }
                }
            }
            WrappingHStack {
                ForEach(allTags) { tag in
                    Button {
                        addTagToSelection(tag)
                    } label: {
                        ProminentTagView(title: tag.wrappedName, isSelected: selectedTags.contains(tag))
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
        .onChange(of: tagName) { text in
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
}

struct TagSelectionView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.preview.container.viewContext
    
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
