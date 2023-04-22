//
//  AddCommentView.swift
//  IssueTracker
//
//  Created by Tino on 1/3/2023.
//

import SwiftUI
import PhotosUI

struct ImageAttachmentsRow: View {
    let images: [Image]
    let deleteAction: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0 ..< images.count, id: \.self) { index in
                    ImageAttachmentPreview(image: images[index]) {
                        deleteAction(index)
                    }
                }
            }
        }
    }
}

struct AddCommentView: View {
    @ObservedObject private(set) var issue: Issue
    @State private var errorWrapper: ErrorWrapper?
    @State private var showingPhotoPicker = false
    @State private var commentProperties = CommentProperties()
    @StateObject private var audioRecorder = AudioRecorder()
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var persistenceController: PersistenceController
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                ImageAttachmentsRow(images: commentProperties.images) { index in
                    commentProperties.deleteImage(at: index)
                }
                
                if !audioRecorder.isRecording, let url = audioRecorder.url {
                    AudioAttachmentPreview(url: url)
                }
                
                TextField("Comment", text: $commentProperties.comment, axis: .vertical)
                    .lineLimit(3...)
                    .textFieldStyle(.roundedBorder)
                
                if commentProperties.isRecordingAudio {
                    audioRecordingButtons
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Add comment")
            .onChange(of: commentProperties.photoPickerItems) { _ in
                Task {
                    do {
                        try await $commentProperties.loadImages()
                    } catch {
                        errorWrapper = .init(error: error, message: "Failed to load photo.")
                    }
                }
            }
            .sheet(item: $errorWrapper) { error in
                ErrorView(errorWrapper: error)
            }
            .toolbar {
                toolbarItems
                keyboardAttachmentButtons
            }
        }
    }
}

private extension AddCommentView {
    @ToolbarContentBuilder
    var toolbarItems: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                Task {
                    do {
                        try await persistenceController.addComment(commentProperties, to: issue)
                        dismiss()
                    } catch {
                        errorWrapper = .init(error: error, message: "Failed to add comment.")
                    }
                }
            } label: {
                Label("Add", systemImage: "plus")
            }
            .disabled(!commentProperties.canAddComment)
        }
    
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", action: dismiss.callAsFunction)
        }
    }
    
    @ToolbarContentBuilder
    var keyboardAttachmentButtons: some ToolbarContent {
        ToolbarItem(placement: .keyboard) {
            PhotosPicker(
                selection: $commentProperties.photoPickerItems,
                selectionBehavior: .ordered,
                matching: .any(of: [.images, .videos])
            ) {
                Label("Add photo attachment", systemImage: "photo.on.rectangle.angled")
                    .labelStyle(.iconOnly)
            }
        }
        
        ToolbarItem(placement: .keyboard) {
            Button {
                withAnimation {
                    commentProperties.toggleRecording()
                }
            } label: {
                Label("Add audio attachment", systemImage: "mic.fill")
            }
            .disabled(audioRecorder.isRecording)
            .labelStyle(.iconOnly)
        }
    }
    
    var audioRecordingButtons: some View {
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
    }
}

struct AddCommentView_Previews: PreviewProvider {
    static var previews: some View {
        AddCommentView(issue: .example)
            .environmentObject(PersistenceController.preview)
    }
}
