//
//  IssueDetail.swift
//  MacIssueTracker
//
//  Created by Tino on 17/1/2023.
//

import SwiftUI

struct IssueDetail: View {
    @ObservedObject var issue: Issue
    
    var body: some View {
            Form {
                Text(issue.name)
                    .font(.system(size: 30))
                Text("Created: \(issue.dateCreated.formatted(date: .abbreviated, time: .shortened))")
                    .foregroundColor(.secondary)
                Section {
                    if issue.issueDescription.isEmpty {
                        Text("No Description")
                            .font(.system(size: 20))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.gray)
                                    
                            }
                    } else {
                        Text(issue.issueDescription)
                            .font(.system(size: 20))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.gray)
                                    
                            }
                    }
                } header: {
                    Text("Description")
                        .font(.system(size: 30))
                }
                
                Section {
                    Text(issue.priority.title)
                        .font(.system(size: 20))
                } header: {
                    Text("Priority")
                        .font(.system(size: 30))
                }
                
                Section {
                    if let tags = issue.tags?.set as? Set<Tag>, tags.isEmpty {
                        Text("No tags")
                            .foregroundColor(.secondary)
                            .font(.system(size: 20))
                    } else {
                        if let tags = issue.tags?.set as? Set<Tag> {
                            ForEach(Array(tags)) { tag in
                                Text(tag.name)
                                    .font(.system(size: 20))
                            }
                        }
                    }
                } header: {
                    Text("Tags")
                        .font(.system(size: 30))
                }
                
                Section {
                    if let comments = issue.comments?.set as? Set<Comment>, comments.isEmpty {
                        Text("No comments")
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading) {
                                if let comments = issue.comments?.set as? Set<Comment> {
                                    ForEach(Array(comments)) { comment in
                                        VStack {
                                            Text(comment.comment)
                                                .font(.system(size: 20))
                                            HStack {
                                                Spacer()
                                                Button {
                                                    // edit button
                                                } label: {
                                                    Label("Edit", systemImage: "rectangle.and.pencil.and.ellipsis")
                                                }
                                                Button(role: .destructive) {
                                                    // delete code
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("Comments")
                            .font(.system(size: 30))
                        Spacer()
                        Button {
                            // todo
                        } label: {
                            Label("Add comment", systemImage: "plus.bubble")
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        
                    }
                }
            }
    }
}

struct IssueDetail_Previews: PreviewProvider {
    static var viewContext = PersistenceController.projectsPreview.container.viewContext
    static var issue = Issue(name: "some issue", issueDescription: "", priority: .low, tags: [], context: viewContext)
    static var previews: some View {
        IssueDetail(issue: issue)
    }
}
