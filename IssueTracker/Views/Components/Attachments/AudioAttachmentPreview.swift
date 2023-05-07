//
//  AudioAttachmentPreview.swift
//  IssueTracker
//
//  Created by Tino on 18/3/2023.
//

import SwiftUI
import AVFoundation

struct AudioAttachmentPreview: View {
    let url: URL
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some View {
        VStack {
            Button(action: playAction) {
                Image(systemName: playIcon)
                    .font(.title)
            }
            Image(systemName: "waveform")
        }
        .padding()
        .background(.white)
        .cornerRadius(7)
        .shadow(radius: 2, x: 0, y: 1)
        .onAppear {
            // TODO: look up how others play audio. (maybe audioPlayer.play(url: url))
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                audioPlayer.setUpPlayer(player: player)
            } catch {
                print("Failed to create player: \(error)")
            }
        }
    }
}

private extension AudioAttachmentPreview {
    var playIcon: String {
        audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill"
    }
    
    func playAction() {
        audioPlayer.isPlaying ? audioPlayer.stop() : audioPlayer.play()
    }
}

struct AudioAttachmentPreview_Previews: PreviewProvider {
    static var previews: some View {
        // TODO: Add preview url here
        AudioAttachmentPreview(url: URL(string: "google.com")!)
    }
}
