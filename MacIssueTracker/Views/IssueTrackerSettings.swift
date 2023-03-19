//
//  IssueTrackerSettings.swift
//  MacIssueTracker
//
//  Created by Tino on 25/1/2023.
//

import SwiftUI

struct IssueTrackerSettings: View {
    @State private var selectedTags = Set<Tag.ID>()
    @StateObject private var viewModel = IssueTrackerSettingsViewModel()
    
    @FetchRequest(sortDescriptors: [.init(\.dateCreated, order: .forward)])
    private var tags: FetchedResults<Tag>
    
    var body: some View {
        Form {
            Text("All tags")
            #warning("selecting anything causes a crash")
            Table(tags, selection: $selectedTags, sortOrder: $tags.sortDescriptors) {
                TableColumn("Name", value: \.name) { tag in
                    TagTableColumn(tag: tag)
                }
                TableColumn("Date created", value: \.dateCreated) { tag in
                    Text(tag.wrappedDateCreated.formatted(date: .numeric, time: .omitted))
                }
            }
            .tableStyle(.bordered)
            
            footerButtons
        }
        .padding()
        .navigationTitle("IssueTracker settings")
        .frame(minWidth: 300, minHeight: 300)
    }
}

private extension IssueTrackerSettings {
    /// The icons the button can have.
    enum ButtonIcon: String {
        case plus = "plus"
        case minus = "minus"
    }
    
    /// Creates an image with the given icon.
    /// - Parameter buttonIcon: The icon for the image.
    /// - Returns: An image with the given icon and a 30x30 frame.
    func buttonImage(_ buttonIcon: ButtonIcon) -> some View {
        Image(systemName: buttonIcon.rawValue)
            .frame(width: 30, height: 30)
            .contentShape(Rectangle())
    }
    
    var footerButtons: some View {
        HStack {
            Button {
                viewModel.addNewTag()
            } label: {
                buttonImage(.plus)
            }
            
            Button {
                viewModel.remove(tags: tags, withIDs: selectedTags)
            } label: {
                buttonImage(.minus)
            }
            .disabled(selectedTags.isEmpty)
        }
        .buttonStyle(.plain)
    }
}

struct IssueTrackerSettings_Previews: PreviewProvider {
    static var viewContext = PersistenceController.tagsPreview.container.viewContext
    
    static var previews: some View {
        IssueTrackerSettings()
            .environment(\.managedObjectContext, viewContext)
    }
}
