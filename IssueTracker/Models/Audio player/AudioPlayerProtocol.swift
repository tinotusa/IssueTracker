//
//  AudioPlayerProtocol.swift
//  IssueTracker
//
//  Created by Tino on 7/5/2023.
//

import AVFoundation

/// Protocol for audio playback.
protocol AudioPlayerProtocol {
    /// Creates an AudioPlayer with the given url.
    /// - Parameter url: The url of the audio.
    init (contentsOf url: URL) throws
    
    /// Prepares the audio player for audio playback.
    /// - Returns: `true` if the player is ready to play, `false` otherwise.
    @discardableResult
    func prepareToPlay() -> Bool
    
    /// Plays the audio.
    /// - Returns: `true` if the player could play the audio, `false` otherwise.
    @discardableResult
    func play() -> Bool
    
    /// Pauses the audio playback.
    func pause()
    
    /// Stops the audio playback.
    func stop()
    
    /// A delegate for the audio player.
    var audioPlayerDelegate: AVAudioPlayerDelegateProtocol? { get set }
    
    /// A boolean value indicatin whether audio is currently playing.
    var isPlaying: Bool { get }
}

protocol AVAudioPlayerDelegateProtocol {
    func didFinishPlaying(_ player: AudioPlayerProtocol, successfully flag: Bool)
}

protocol AVAudioSessionProtocol {
    /// Sets the sessions category.
    /// - Parameter category: The category to set.
    func setCategory(_ category: AVAudioSession.Category) throws
    func requestRecordPermission(_ response: @escaping (Bool) -> Void)
}

extension AVAudioSession: AVAudioSessionProtocol { }
