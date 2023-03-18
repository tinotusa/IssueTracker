//
//  AddCommentView.swift
//  IssueTracker
//
//  Created by Tino on 1/3/2023.
//

import SwiftUI
import PhotosUI

struct AddCommentView: View {
    @ObservedObject private(set) var issue: Issue
    
    @StateObject private var viewModel = AddCommentViewModel()
    @StateObject private var audioRecorder = AudioRecorder()
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                imageAttachmentsRow
                
                if !audioRecorder.isRecording, let url = audioRecorder.url {
                    AudioAttachmentPreview(url: url)
                }
                
                if viewModel.recordingAudio {
                    audioRecordingButtons
                }
            }
            .safeAreaInset(edge: .bottom) {
                TextField("Comment", text: $viewModel.comment, axis: .vertical)
                    .lineLimit(3...)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            .navigationTitle("Add comment")
            .onChange(of: viewModel.photoPickerItems) { photoItems in
                Task {
                    await viewModel.loadImages(from: photoItems)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await viewModel.addComment(issue: issue, viewContext: viewContext, audioURL: audioRecorder.url)
                            dismiss()
                        }
                    } label: {
                        Label("add", systemImage: "plus")
                    }
                    .disabled(!viewModel.hasComment || audioRecorder.isRecording)
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
                ForEach(0 ..< viewModel.attachmentImages.count, id: \.self) { index in
                    ImageAttachmentPreview(image: viewModel.attachmentImages[index]) {
                        viewModel.deletePhotoItem(at: index)
                    }
                }
            }
        }
    }
    
    var attachmentButtons: some View {
        HStack {
            PhotosPicker(
                selection: $viewModel.photoPickerItems,
                selectionBehavior: .ordered,
                matching: .any(of: [.images, .videos])
            ) {
                Label("Add photo attachment", systemImage: "photo.on.rectangle.angled")
            }
            Button {
                withAnimation {
                    viewModel.recordingAudio.toggle()
                }
            } label: {
                Label("Add audio attachment", systemImage: "mic.fill")
            }
            .disabled(audioRecorder.isRecording)
        }
        .labelStyle(.iconOnly)
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
    }
}
