//
//  AudioPlayerTests.swift
//  IssueTrackerTests
//
//  Created by Tino on 6/5/2023.
//

import XCTest
@testable import IssueTracker

final class AudioPlayerTests: XCTestCase {
    private var audioPlayer: AudioPlayer!
    private var player: MockAudioPlayer!

    override func setUpWithError() throws {
        let session = MockAudioSession()
        try session.setCategory(.playback)
        audioPlayer = AudioPlayer(session: session)
        player = try MockAudioPlayer(contentsOf: URL(string: "www.google.com")!)
    }

    func testSetUpPlayerSetsUpCorrectly() throws {
        audioPlayer.setUpPlayer(player: player)
        XCTAssertNotNil(audioPlayer.player?.audioPlayerDelegate, "Player's audio player delegate should not be nil.")
        XCTAssertFalse(player.isPlaying, "Player should not be playing yet.")
    }
    
    func testSessionThrowsError() throws {
        let session = MockAudioSession()
        session.throwSessionError = true
        let _ = AudioPlayer(session: session)
    }
    
    func testPlayWithoutCallingSetUpPlayer() async {
        await audioPlayer.play()
        XCTAssertFalse(audioPlayer.isPlaying, "Player should not be playing.")
    }
    
    func testPlay() async {
        setUpPlayer()
        await audioPlayer.play()
        audioPlayer.setUpPlayer(player: player)
        XCTAssertTrue(audioPlayer.isPlaying, "Player should have started playing.")
        audioPlayer.didFinishPlaying(player, successfully: true)
        XCTAssertFalse(audioPlayer.isPlaying, "Player should not be playing after stopping.")
    }
    
    func testPlayReturnsIfAlreadyPlaying() async {
        setUpPlayer()
        await audioPlayer.play()
        await audioPlayer.play()
        XCTAssertTrue(player.isPlaying, "Player should still be playing.")
    }
    
    func testPause() async {
        setUpPlayer()
        await playAudio()
        await audioPlayer.pause()
        XCTAssertFalse(audioPlayer.isPlaying, "Player should have paused.")
    }
    
    func testStop() async {
        setUpPlayer()
        await playAudio()
        await audioPlayer.stop()
        XCTAssertFalse(audioPlayer.isPlaying, "Player should have stopped playing.")
    }
    
    private func playAudio() async {
        await audioPlayer.play()
        XCTAssertTrue(audioPlayer.isPlaying, "Player should be playing.")
    }
    
    private func setUpPlayer() {
        audioPlayer.setUpPlayer(player: player)
        XCTAssertNotNil(audioPlayer.player?.audioPlayerDelegate, "Player's audio player delegate should not be nil.")
        XCTAssertFalse(audioPlayer.isPlaying, "Player shouldn't be playing.")
    }
}
