//
//  AudioPlayer.swift
//  IssueTracker
//
//  Created by Tino on 9/3/2023.
//

import Foundation
import os
import AVFoundation

/// Wrapper for AVAudioPlayer.
class AudioPlayer: NSObject, ObservableObject {
    /// A boolean value indicating whether the AVAudioPlayer is playing.
    @Published private(set) var isPlaying = false
    
    /// The audio player.
    private(set) var player: AudioPlayerProtocol?
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AudioPlayer.self)
    )
    private let session: AVAudioSessionProtocol
    
    /// Create a new AudioPlayer with a given session.
    /// - Parameter session: The session used by the class.
    init(session: AVAudioSessionProtocol = AVAudioSession.sharedInstance()) {
        self.session = session
        do {
            try session.setCategory(.playback)
        } catch {
            logger.error("Failed to init AudioPlayer. \(error)")
        }
    }
}

// MARK: - Functions
extension AudioPlayer {
    /// Sets up the audio player.
    /// - Parameter player: The player used for audio playback.
    func setUpPlayer(player: AudioPlayerProtocol) {
        self.player = player
        self.player?.prepareToPlay()
        self.player?.audioPlayerDelegate = self
    }
    
    /// Plays the audio if the player is not nil.
    @MainActor
    func play() {
        guard let player else {
            logger.debug("Failed to play audio. player is nil")
            return
        }
        if isPlaying { return }
        player.play()
        isPlaying = player.isPlaying
    }
    
    /// Pauses the audio playback.
    @MainActor
    func pause() {
        guard let player else {
            logger.debug("Failed to pause audio player. player is nil.")
            return
        }
        if !player.isPlaying { return }
        player.pause()
        isPlaying = player.isPlaying
        logger.debug("Paused audio player.")
    }
    
    /// Stops the audio play back.
    @MainActor
    func stop() {
        guard let player else {
            logger.debug("Failed to stop audio. player is nil.")
            return
        }
        if !player.isPlaying { return }
        player.stop()
        isPlaying = player.isPlaying
    }
}

// MARK: - Protocol Extensions
extension AVAudioPlayer: AudioPlayerProtocol {
    var audioPlayerDelegate: AVAudioPlayerDelegateProtocol? {
        get { return delegate as! AVAudioPlayerDelegateProtocol? }
        set { delegate = newValue as! AVAudioPlayerDelegate? }
    }
}

extension AudioPlayer: AVAudioPlayerDelegateProtocol {
    func didFinishPlaying(_ player: AudioPlayerProtocol, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.didFinishPlaying(player, successfully: flag)
    }
}
