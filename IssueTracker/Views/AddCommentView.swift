//
//  AddCommentView.swift
//  IssueTracker
//
//  Created by Tino on 1/3/2023.
//

import SwiftUI
import Combine
import PhotosUI
import AVFAudio

struct AddCommentView: View {
    @ObservedObject var issue: Issue
    @State private var comment = ""
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var recordingAudio = false // will probably change this
    @State private var showingPhotoPicker = false
    @State private var photos = [PhotosPickerItem]()
    @State private var paths = [URL]()
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
                            if recordingAudio {
                                audioRecorder.setUpRecorder()
                            }
                        }
                    } label: {
                        Label("Add audio attachment", systemImage: "mic.fill")
                    }
                    .disabled(audioRecorder.isRecording)
                }
                .labelStyle(.iconOnly)
                Button("list paths") {
                    Task {
                        paths = await getImagePaths()
                    }
                }
                Text(errorMessage)
                    .foregroundColor(.red)
                ForEach(paths, id: \.self) { path in
                    Text(path.relativeString)
                }
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
                        let comment = Comment(comment: comment, context: viewContext)
                        issue.addToComments(comment)
                        do {
                            try viewContext.save()
                        } catch {
                            print("Failed to save context. \(error)")
                        }
                        dismiss()
                    } label: {
                        Label("add", systemImage: "plus")
                    }
                    .disabled(comment.isEmpty)
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

import os

class AudioPlayer: NSObject, ObservableObject {
    private var player: AVAudioPlayer?
    private let log = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AudioPlayer.self)
    )
    @Published var isPlaying = false
    
    func setUpPlayer(url: URL) {
        do {
            player = try .init(contentsOf: url)
            player?.prepareToPlay()
            player?.delegate = self
        } catch {
            log.error("Failed to set up player. \(error)")
        }
    }
    
    @MainActor
    func play() {
        guard let player else {
            log.debug("Failed to play audio. player is nil")
            return
        }
        if isPlaying { return }
        player.play()
        isPlaying = player.isPlaying
    }
    
    @MainActor
    func pause() {
        guard let player else {
            log.debug("Failed to pause audio player. player is nil.")
            return
        }
        player.pause()
        isPlaying = player.isPlaying
        log.debug("Paused audio player.")
    }
    
    @MainActor
    func stop() {
        guard let player else {
            log.debug("Failed to stop audio. player is nil.")
            return
        }
        player.stop()
        isPlaying = player.isPlaying
    }
    
    var duration: TimeInterval {
        player?.duration ?? .zero
    }
    
    var currentTime: TimeInterval {
        player?.currentTime ?? .zero
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }
}

class AudioRecorder: ObservableObject {
    private var recorder: AVAudioRecorder?
    @Published private(set) var isRecording = false
    private let log = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AudioRecorder.self)
    )
    @Published private(set) var url: URL?
    
    func setUpRecorder() {
        do {
            let attachmentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "attachmentsFolder")
            if !FileManager.default.fileExists(atPath: attachmentsFolder.path()) {
                try FileManager.default.createDirectory(at: attachmentsFolder, withIntermediateDirectories: true)
            }
            let audioFileURL = attachmentsFolder.appending(path: UUID().uuidString)
            url = audioFileURL
            recorder = try .init(url: audioFileURL, settings: [:])
//            recorder?.prepareToRecord()
        } catch {
            log.error("Failed to set up recorder. \(error)")
        }
    }
    
    @MainActor
    func startRecording() {
        log.debug("Starting to record audio.")
        if isRecording {
            log.debug("Already recording.")
            return
        }

        guard let recorder else {
            log.debug("Failed to start recorder. recorder is nil.")
            return
        }

        recorder.prepareToRecord()
        recorder.record()
        isRecording = recorder.isRecording
    }
    
    @MainActor
    func stopRecording() {
        guard let recorder else {
            log.debug("Recorder is nil.")
            return
        }
        if !isRecording {
            return
        }
        recorder.stop()
        isRecording = recorder.isRecording
        log.debug("Stopped recording.")
    }
    
    @MainActor
    func pauseRecording() {
        guard let recorder else {
            log.debug("Cannot pause recording recorder is nil.")
            return
        }
        recorder.pause()
        isRecording = recorder.isRecording
    }
    
    @MainActor
    func deleteRecording() {
        guard let recorder else {
            log.debug("Failed to delete recording. recorder is nil.")
            return
        }
        if isRecording {
            log.debug("Failed to delete recording. recorder is still recording.")
            return
        }
        let fileWasDeleted = recorder.deleteRecording()
        if !fileWasDeleted {
            log.error("Failed to delete audio recording.")
        }
        url = nil
        log.debug("Successfully deleted audio recording.")
    }
}

enum AttachmentType: Int16 {
    case image
    case video
    case audio
}

// TODO: Rename to something like Attachment (can't use Attachment because that is a coredata entity)
struct JPEGTest: Transferable {
    let url: URL
    let attachmentType: AttachmentType
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .jpeg) { jpeg in
            return SentTransferredFile(jpeg.url)
        } importing: { received in
            let attachmentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "attachmentsFolder/")
            if !FileManager.default.fileExists(atPath: attachmentsFolder.path()) {
                do {
                    print("Folder doesn't exist trying to create a new one")
                    try FileManager.default.createDirectory(atPath: attachmentsFolder.path(), withIntermediateDirectories: true)
                    print("Successfully created new folder.")
                } catch {
                    print("Failed to create directory. \(error)")
                }
            }
            
            let copy = attachmentsFolder.appending(path: UUID().uuidString)
            print("the received file is: \(received.file)")
            print("the copy path is:  \(copy)")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy, attachmentType: .image)
        }
        
        // TODO: These file reps are the exact same. Is there a way to change this?
        FileRepresentation(contentType: .png) { png in
            return SentTransferredFile(png.url)
        } importing: { received in
            let attachmentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "attachmentsFolder/")
            if !FileManager.default.fileExists(atPath: attachmentsFolder.path()) {
                do {
                    print("Folder doesn't exist trying to create a new one")
                    try FileManager.default.createDirectory(atPath: attachmentsFolder.path(), withIntermediateDirectories: true)
                    print("Successfully created new folder.")
                } catch {
                    print("Failed to create directory. \(error)")
                }
            }
            
            let copy = attachmentsFolder.appending(path: UUID().uuidString)
            print("the received file is: \(received.file)")
            print("the copy path is:  \(copy)")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy, attachmentType: .image)
        }
    }
}

private extension AddCommentView {
    static let attachmentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "attachmentsFolder")
    func getImagePaths() async -> [URL] {
        self.paths = []
        var paths = [URL]()
        do {
            for photo in photos {
                let data = try await photo.loadTransferable(type: JPEGTest.self)
                guard let data else {
                    print("failed to get image data")
                    continue
                }
//                try data.write(to: filePath, options: [.atomic, .completeFileProtection])
                paths.append(data.url)
            }
        } catch {
            errorMessage = "Failed to get image paths. \(error)"
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
