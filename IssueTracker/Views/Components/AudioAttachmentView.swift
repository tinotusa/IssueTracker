//
//  AudioAttachmentView.swift
//  IssueTracker
//
//  Created by Tino on 18/3/2023.
//

import SwiftUI

struct AudioAttachmentView: View {
    let url: URL
    @State private var audioURL: URL?
    @StateObject private var audioPlayer = AudioPlayer()
    private let attachmentLoader = AttachmentLoader()
    
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
            Task {
                do {
                    audioURL = try await attachmentLoader.getAttachmentAssetURL(fromURL: url)
                } catch {
                    // TODO: Do something else here.
                    print("Something went wrong \(error)")
                }
            }
        }
    }
}

struct AudioAttachmentView_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: Change this url
        AudioAttachmentView(url: URL(string: "google.com")!)
    }
}
