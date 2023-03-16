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
    @ObservedObject private(set) var issue: Issue
    @State private var comment = ""
    @State private var recordingAudio = false // will probably change this
    @State private var showingPhotoPicker = false
    @State private var photos = [PhotosPickerItem]()
    @State private var attachmentImages: [Image] = []
    
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var audioPlayer = AudioPlayer()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .trailing) {
                imageAttachmentsRow
                if audioRecorder.url != nil {
                    AudioAttachmentIcon(url: audioRecorder.url!)
                }
                if recordingAudio {
                    audioRecordingButtons
                }
            }
            .safeAreaInset(edge: .bottom) {
                TextField("Comment", text: $comment, axis: .vertical)
                    .lineLimit(3...)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            .navigationTitle("Add comment")
            .onChange(of: photos) { photoItems in
                Task {
                    await loadImages(from: photoItems)
                }
            }
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
                ToolbarItem(placement: .keyboard) {
                    attachmentButtons
                }
            }
        }
    }
}

private extension AddCommentView {
    var imageAttachmentsRow: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0 ..< attachmentImages.count, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        attachmentImages[index]
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .cornerRadius(10)
                        Button(role: .destructive) {
                            photos.remove(at: index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    
    var attachmentButtons: some View {
        HStack {
            PhotosPicker(
                selection: $photos,
                selectionBehavior: .ordered,
                matching: .any(of: [.images, .videos])
            ) {
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
    }
    
    var audioRecordingButtons: some View {
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
                        systemImage: audioRecorder.isRecording ? "pause.circle.fill" : "play.circle.fill"
                    )
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

private extension AddCommentView {
    func loadImages(from photoItems: [PhotosPickerItem]) async {
        do {
            var attachmentImages: [Image] = []
            for photo in photoItems {
                
                guard let data = try await photo.loadTransferable(type: Data.self) else {
                    continue
                }
                guard let uiImage = UIImage(data: data) else {
                    continue
                }
                let image = Image(uiImage: uiImage)
                attachmentImages.append(image)
            }
            self.attachmentImages = attachmentImages
        } catch {
            // TODO: Display error message if one arises
            print("error \(error)")
        }
    }
    
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
        var paths = [AttachmentTransferable]()
        do {
            for photo in photos {
                let data = try await photo.loadTransferable(type: AttachmentTransferable.self)
                guard let data else {
                    print("failed to get image data")
                    continue
                }
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
