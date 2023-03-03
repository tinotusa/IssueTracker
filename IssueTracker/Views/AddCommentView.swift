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
                            recordingAudio = true
                        }
                    } label: {
                        Label("Add audio attachment", systemImage: "mic.fill")
                    }
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
                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.red)
                        Button {
                            recordingAudio = false
                        } label: {
                            Label("Stop recording", systemImage: "stop.circle.fill")
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
