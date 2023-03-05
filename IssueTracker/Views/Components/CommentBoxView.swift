//
//  CommentBoxView.swift
//  IssueTracker
//
//  Created by Tino on 30/12/2022.
//

import SwiftUI
import CloudKit

struct ImageAttachmentIcon: View {
    let url: URL
    @State private var imageURL: URL?
    
    var body: some View {
        Group {
            if let imageURL {
                AsyncImage(url: imageURL)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .frame(width: 50, height: 50)
        .cornerRadius(10)
        .task {
            let query = CKQuery(
                recordType: "Attachment",
                predicate: .init(format: "attachmentURL == %@", url.absoluteString)
            )
            
            let operation = CKQueryOperation(query: query)
            operation.resultsLimit = 1
            operation.recordMatchedBlock = { id, result in
                switch result {
                case .failure(let error):
                    print("Error failed to get asset: \(error)")
                case .success(let record):
                    guard let asset = record["attachment"] as? CKAsset,
                          let url = asset.fileURL
                    else {
                        print("failed to get asset or url")
                        return
                    }
                    self.imageURL = url
                }
            }
            // TODO: change to use results block
            operation.start()
        }
    }
}

struct AudioAttachmentIcon: View {
    let url: URL
    @State private var audioURL: URL?
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some View {
        Group {
            if audioURL != nil {
                VStack {
                    Button {
                        if audioPlayer.isPlaying {
                            audioPlayer.stop()
                        } else {
                            audioPlayer.play()
                        }
                    } label: {
                        Image(systemName: audioPlayer.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title)
                    }
                    Image(systemName: "waveform")
                        .foregroundColor(audioPlayer.isPlaying ? .blue : .secondary)
                }
                .onAppear {
                    audioPlayer.setUpPlayer(url: URL(filePath: audioURL!.path()))
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.white)
                .cornerRadius(10)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(width: 50, height: 50)
            }
        }
        .onAppear {
            print("audio attachment appeared")
            let query = CKQuery(
                recordType: "Attachment",
                predicate: .init(format: "attachmentURL == %@", url.absoluteString)
            )
            var url: URL? = nil
            let operation = CKQueryOperation(query: query)
            operation.resultsLimit = 1
            operation.recordMatchedBlock = { id, result in
                print("in match block")
                switch result {
                case .failure(let error):
                    print("Failed to get audio record. \(error)")
                case .success(let record):
                    guard let asset = record["attachment"] as? CKAsset else {
                        print("failed to get audio asset")
                        return
                    }
                    url = asset.fileURL
                    print("Successfully got the audio url: \(url)")
                }
            }
            operation.queryResultBlock = { result in
                switch result {
                case.success(let cursor):
                    print("successfully got the data \(cursor)")
                    self.audioURL = url
                case .failure(let error):
                    print("failed to get audio from cloudkit. \(error)")
                }
            }
            print("set icloud record block")
            operation.start()
            print("after opertation start")
        }
    }
}

struct CommentBoxView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var comment: Comment
    let issue: Issue
    @State private var isEditing = false
    @State private var showingDeleteConfirmation = false
    @State private var originalComment = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                TextEditor(text: $comment.comment)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 30)
            } else {
                Text(comment.comment)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(comment.wrappedAttachments) { attachment in
                            let attachmentType = AttachmentType(rawValue: attachment.type_)!
                            switch attachmentType {
                            case .audio:
                                AudioAttachmentIcon(url: attachment.assetURL_!)
                            case .image:
                                ImageAttachmentIcon(url: attachment.assetURL_!)
                            case .video:
                                Text("TODO")
                            }
                        }
                    }
                }
            }
            HStack {
                Text(comment.dateCreated.formatted(date: .abbreviated, time: .omitted))
                    .footerStyle()
                Spacer()
                if isEditing {
                    Button("Save") {
                        issue.addToComments(comment)
                        withAnimation {
                            isEditing = false
                        }
                        try? viewContext.save()
                    }
                    Button("Cancel") {
                        comment.comment = originalComment
                        withAnimation {
                            isEditing = false
                        }
                    }
                } else {
                    Button {
                        originalComment = comment.comment
                        withAnimation {
                            isEditing = true
                        }
                    } label: {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    }
                }
                if !isEditing {
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .padding()
        .background(Color.popup)
        .cornerRadius(10)
        .confirmationDialog("Delete comment", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {   
                issue.removeFromComments(comment)
                // TODO: Delete the attachment files as well.
                withAnimation {
                    try? viewContext.save()
                }
            }
        } message: {
            Text("Delete this comment.")
        }
    }
}

struct CommentBoxView_Previews: PreviewProvider {
    static let viewContext = PersistenceController.issuesPreview.container.viewContext
    
    static var previews: some View {
        CommentBoxView(
            comment: .init(comment: "testing", context: viewContext),
            issue: .init(name: "test", issueDescription: "", priority: .low, tags: [], context: viewContext)
        )
    }
}
