//
//  AudioAttachmentView.swift
//  IssueTracker
//
//  Created by Tino on 18/3/2023.
//

import SwiftUI

struct AudioAttachmentView: View {
    let url: URL
    @StateObject private var audioPlayer = AudioPlayer()
    private let attachmentLoader = AttachmentLoader()
    @State private var loadingState: AttachmentLoadingState = .loading
    
    let size = 80.0
    
    var body: some View {
        Group {
            switch loadingState {
            case .loading:
                    loadingView
            case .loaded(let assetURL):
                loadedView(assetURL: assetURL)
            case .urlNotFound:
                AttachmentLoadingErrorView(errorType: .notFound)
            case .error:
                AttachmentLoadingErrorView(errorType: .error)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Subviews
private extension AudioAttachmentView {
    var loadingView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .onAppear(perform: loadAsset)
    }
    
    func loadedView(assetURL: URL) -> some View {
        VStack {
            Button(action: playAudio) {
                Image(systemName: audioPlayer.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title)
            }
            Image(systemName: "waveform")
                .foregroundColor(audioPlayer.isPlaying ? .blue : .secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.white)
        .cornerRadius(10)
        .onAppear {
            audioPlayer.setUpPlayer(url: URL(filePath: assetURL.path()))
        }
    }
}

// MARK: - Functions
private extension AudioAttachmentView {
    func loadAsset() {
        Task {
            do {
                loadingState = .loading
                let audioURL = try await attachmentLoader.getAttachmentAssetURL(fromURL: url)
                guard let audioURL else {
                    loadingState = .urlNotFound
                    return
                }
                loadingState = .loaded(url: audioURL)
            } catch {
                loadingState = .error(error: error)
            }
        }
    }
    
    func playAudio() {
        if audioPlayer.isPlaying {
            audioPlayer.stop()
        } else {
            audioPlayer.play()
        }
    }
}

// MARK: - Previews
struct AudioAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: Change this url
        AudioAttachmentView(url: URL(string: "google.com")!)
    }
}
