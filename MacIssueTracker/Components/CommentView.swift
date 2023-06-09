//
//  CommentView.swift
//  MacIssueTracker
//
//  Created by Tino on 21/1/2023.
//

import SwiftUI

struct CommentView: View {
    @ObservedObject var comment: Comment
    @Environment(\.managedObjectContext) private var viewContext
    @State private var commentChange = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(comment.wrappedDateCreated.formatted(date: .long, time: .omitted))
                .secondaryFootnote()
            HStack {
                TextEditor(text: $commentChange.animation())
//                    .scrollContentBackground(.hidden) // don't have mac os 13
                
                Spacer()
                HStack {
                    if commentChange != comment.comment {
                        Button {
                            comment.comment = commentChange
                            withAnimation {
                                try? viewContext.save()
                            }
                        } label: {
                            Label("Save", systemImage: SFSymbol.pencil.rawValue)
                        }
                        Button {
                            withAnimation {
                                commentChange = comment.wrappedComment
                            }
                        } label: {
                            Label("Cancel", systemImage: SFSymbol.pencilSlash.rawValue)
                        }
                    }
                    Button(role: .destructive) {
                        viewContext.delete(comment)
                        try? viewContext.save()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                }
            }
            
            Divider()
        }
        .bodyStyle()
        .onAppear {
            commentChange = comment.wrappedComment
        }
    }
}

struct CommentView_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    static var comment = Comment(comment: "Lorem", context: viewContext)
    
    static var previews: some View {
        CommentView(comment: comment)
            .environment(\.managedObjectContext, viewContext)
    }
}
