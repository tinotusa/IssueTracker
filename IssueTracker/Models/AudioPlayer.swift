//
//  AudioPlayer.swift
//  IssueTracker
//
//  Created by Tino on 9/3/2023.
//

import Foundation
import os
import AVFoundation

class AudioPlayer: NSObject, ObservableObject {
    private var player: AVAudioPlayer?
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AudioPlayer.self)
    )
    @Published var isPlaying = false
    private let session: AVAudioSession
    
    override init() {
        session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback)
        } catch {
            logger.error("Failed to init AudioPlayer. \(error)")
        }
        super.init()
    }
    
    func setUpPlayer(url: URL) {
        do {
            player = try .init(contentsOf: url)
            player?.prepareToPlay()
            player?.delegate = self
        } catch {
            logger.error("Failed to set up player. \(error)")
        }
    }
    
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
    
    @MainActor
    func pause() {
        guard let player else {
            logger.debug("Failed to pause audio player. player is nil.")
            return
        }
        player.pause()
        isPlaying = player.isPlaying
        logger.debug("Paused audio player.")
    }
    
    @MainActor
    func stop() {
        guard let player else {
            logger.debug("Failed to stop audio. player is nil.")
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
