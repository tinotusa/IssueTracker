//
//  AudioAttachmentView.swift
//  IssueTracker
//
//  Created by Tino on 18/3/2023.
//

import SwiftUI
import CloudKit

struct AudioAttachmentView: View {
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
            loadAudioAttachment()
        }
    }
}

private extension AudioAttachmentView {
    func loadAudioAttachment() {
        let query = CKQuery(
            recordType: "Attachment",
            predicate: .init(format: "attachmentURL == %@", url.absoluteString)
        )
        var url: URL?
        let operation = CKQueryOperation(query: query)
        operation.qualityOfService = .userInitiated
        
        operation.recordMatchedBlock = { id, result in
            switch result {
            case .failure(let error):
                print("Failed to get audio record. \(error)")
            case .success(let record):
                guard let asset = record["attachment"] as? CKAsset else {
                    print("failed to get audio asset")
                    return
                }
                url = asset.fileURL
            }
        }
        operation.queryResultBlock = { result in
            switch result {
            case.success(_):
                DispatchQueue.main.async {
                    self.audioURL = url
                }
            case .failure(let error):
                print("failed to get audio from cloudkit. \(error)")
            }
        }
        let database = CKContainer.default().privateCloudDatabase
        database.add(operation)
    }
}
struct AudioAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: Change this url
        AudioAttachmentView(url: URL(string: "google.com")!)
    }
}
