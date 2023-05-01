//
//  AddCommentBox.swift
//  IssueTracker
//
//  Created by Tino on 1/3/2023.
//

import SwiftUI
import PhotosUI

struct AddCommentBox: View {
    let postAction: (CommentProperties) -> Void
    
    @State private var errorWrapper: ErrorWrapper?
    @State private var showingPhotoPicker = false
    @State private var showingAudioControls = false
    
    @StateObject private var commentProperties = CommentProperties()
    @StateObject private var audioRecorder = AudioRecorder()
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            ImageAttachmentsRow(images: commentProperties.images)
            
            if !audioRecorder.isRecording, let url = audioRecorder.url {
                AudioAttachmentPreview(url: url)
            }
            
            HStack {
                photoPickerButton
                audioRecorderButton
            }
            
            HStack {
                TextField("Add your comment here", text: $commentProperties.comment, axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                Button("Post") {
                    postAction(commentProperties)
                }
                .disabled(!commentProperties.hasValidComment)
            }
            if showingAudioControls {
                audioRecordingControlButtons
            }
        }
        .onChange(of: commentProperties.photoPickerItems) { _ in
            Task {
                do {
                    try await commentProperties.loadImages()
                } catch {
                    errorWrapper = .init(error: error, message: "Failed to load images")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isFocused = false
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

// MARK: - Views
private extension AddCommentBox {
    var photoPickerButton: some View {
        PhotosPicker(
            selection: $commentProperties.photoPickerItems,
            selectionBehavior: .ordered,
            matching: .any(of: [.images, .videos])
        ) {
            Label("Add photo attachment", systemImage: SFSymbol.photoOnRectangleAngled)
                .labelStyle(.iconOnly)
        }
    }
    
    var audioRecorderButton: some View {
        Button {
            showingAudioControls.toggle()
        } label: {
            Label("Add audio attachment", systemImage: SFSymbol.micFill)
        }
        .disabled(audioRecorder.isRecording)
        .labelStyle(.iconOnly)
    }
    
    var audioRecordingControlButtons: some View {
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
                    systemImage: audioRecorder.isRecording ? SFSymbol.pauseCircleFill : SFSymbol.playCircleFill
                )
            }
            
            Button(role: .destructive) {
                audioRecorder.deleteRecording()
            } label: {
                Label("Delete recording", systemImage: SFSymbol.trash)
            }
            .disabled(audioRecorder.isRecording)
        }
        .labelStyle(.iconOnly)
    }
}

struct AddCommentBox_Previews: PreviewProvider {
    static var previews: some View {
        AddCommentBox() { _ in
            // no post action for previews
        }
    }
}
