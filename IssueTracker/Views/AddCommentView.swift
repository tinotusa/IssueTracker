//
//  AddCommentView.swift
//  IssueTracker
//
//  Created by Tino on 1/3/2023.
//

import SwiftUI
import PhotosUI
import CloudKit

struct AddCommentView: View {
    @ObservedObject var issue: Issue
    @State private var comment = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var recordingAudio = false // will probably change this
    @State private var showingPhotoPicker = false
    @State private var photos = [PhotosPickerItem]()
    @State private var paths = [AttachmentTransferable]()
    @State private var errorMessage = ""
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
                TextField("Comment", text: $comment, axis: .vertical)
                    .lineLimit(3...)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    PhotosPicker(selection: $photos, matching: .any(of: [.images, .videos])) {
                        Label("Add photo attachment", systemImage: "photo.on.rectangle.angled")
                    }
                    Button {
                        withAnimation {
                            recordingAudio.toggle()
                        }
                    } label: {
                        Label("Add audio attachment", systemImage: "mic.fill")
                    }
                    .disabled(audioRecorder.isRecording)
                }
                .labelStyle(.iconOnly)
                
                if recordingAudio {
                    VStack {
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(.red)
                            
                            Button {
                                if audioRecorder.isRecording {
                                    audioRecorder.stopRecording()
                                } else {
                                    audioRecorder.startRecording()
                                }
                            } label: {
                                Label(
                                    audioRecorder.isRecording ? "Stop recording" : "Start recording",
                                    systemImage: audioRecorder.isRecording ? "pause.circle.fill" : "play.circle.fill")
                            }
                            Button(role: .destructive) {
                                audioRecorder.deleteRecording()
                            } label: {
                                Label("Delete recording", systemImage: "trash")
                            }
                            .disabled(audioRecorder.isRecording)
                        }
                        .labelStyle(.iconOnly)
                        if !audioRecorder.isRecording && audioRecorder.url != nil {
                            HStack {
                                Button {
                                    audioPlayer.setUpPlayer(url: audioRecorder.url!)
                                    if audioPlayer.isPlaying {
                                        audioPlayer.pause()
                                    } else {
                                        audioPlayer.play()
                                    }
                                } label: {
                                    Label(
                                        audioPlayer.isPlaying ? "Pause playing" : "Start playing",
                                        systemImage: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill"
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Add comment")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await addComment()
                        }
                    } label: {
                        Label("add", systemImage: "plus")
                    }
                    .disabled(comment.isEmpty || audioRecorder.isRecording)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private extension AddCommentView {
    func addComment() async {
        let comment = Comment(comment: comment, context: viewContext)
        let paths = await getImagePaths()
        var attachments = [Attachment]()
        for path in paths {
            let attachment = Attachment(context: viewContext)
            attachment.comment = comment
            attachment.dateCreated_ = .now
            attachment.id_ = UUID()
            attachment.type_ = path.attachmentType.rawValue
            attachment.assetURL_ = path.url
            attachments.append(attachment)
        }
        // adding audio
        if let audioURL = audioRecorder.url {
            print("trying to save audio.")
            let asset = CKAsset(fileURL: audioURL)
            let record = CKRecord(recordType: "Attachment")
            record.setValuesForKeys([
                "type": AttachmentType.audio.rawValue,
                "attachment": asset,
                "attachmentURL": audioURL.absoluteString
            ])
            let database = CKContainer.default().privateCloudDatabase
            do {
                try await database.save(record)
            } catch {
                print("Failed to save audio record to iCloud")
            }
            let attachment = Attachment(context: viewContext)
            attachment.comment = comment
            attachment.dateCreated_ = .now
            attachment.id_ = UUID()
            attachment.type_ = AttachmentType.audio.rawValue
            attachment.assetURL_ = asset.fileURL!
            print("added audio url to core data attachment.")
            attachments.append(attachment)
        }
        issue.addToComments(comment)
        comment.addToAttachments(.init(array: attachments))
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context. \(error)")
        }
        dismiss()
    }
    
    func getImagePaths() async -> [AttachmentTransferable] {
        self.paths = []
        var paths = [AttachmentTransferable]()
        do {
            for photo in photos {
                let data = try await photo.loadTransferable(type: AttachmentTransferable.self)
                guard let data else {
                    print("failed to get image data")
                    continue
                }
                // TODO: Look up how to store things in cloud kit
//                try data.write(to: filePath, options: [.atomic, .completeFileProtection])
                paths.append(data)
            }
        } catch {
            print("Failed to get image paths. \(error)")
        }
        return paths
    }
}

struct AddCommentView_Previews: PreviewProvider {
    static var previews: some View {
        AddCommentView(issue: .example)
    }
}
