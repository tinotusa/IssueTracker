//
//  AudioRecorderTests.swift
//  IssueTrackerTests
//
//  Created by Tino on 7/5/2023.
//

import XCTest
@testable import IssueTracker

final class AudioRecorderTests: XCTestCase {
    private var audioRecorder: AudioRecorder!
    private var recorder: MockAudioRecorder!
    private var session: MockAudioSession!
    
    override func setUpWithError() throws {
        session = MockAudioSession()
        try session.setCategory(.record)
        audioRecorder = AudioRecorder(session: session)
        recorder = try MockAudioRecorder(url: URL(string: "www.google.com")!, settings: [:])
    }

    func testHasPermission() async throws {
        let hasPermission = audioRecorder.requestPermission()
        XCTAssertTrue(hasPermission, "Audio recorder should have been granted permission.")
    }
    
    func testPermissionNotGranted() {
        session.hasPermission = false
        let hasPermission = audioRecorder.requestPermission()
        XCTAssertFalse(hasPermission, "Audio recorder shouldn't have permission.")
    }
    
    func testStartRecording() async throws {
        await audioRecorder.startRecording(recorder: recorder)
        XCTAssertEqual(audioRecorder.url, recorder.url, "Audio recorder url does't match recorder's url.")
        XCTAssertNotNil(audioRecorder.recorder, "Audio recorder's recorder is nil.")
        XCTAssertTrue(audioRecorder.isRecording, "Audio recorder should be recording.")
    }
    
    func testStartRecordingWithoutPermission() async throws {
        session.hasPermission = false
        await audioRecorder.startRecording(recorder: recorder)
        XCTAssertFalse(audioRecorder.isRecording)
    }
    
    func testStartRecordingWhileAlreadyRecording() async {
        await audioRecorder.startRecording(recorder: recorder)
        await audioRecorder.startRecording(recorder: recorder)
        XCTAssertTrue(audioRecorder.isRecording, "Audio recorder should be recording.")
    }
    
    func testStopRecording() async {
        await audioRecorder.startRecording(recorder: recorder)
        XCTAssertTrue(audioRecorder.isRecording, "Audio recorder should be recording.")
        await audioRecorder.stopRecording()
        XCTAssertFalse(audioRecorder.isRecording, "Audio recorder should have stopped recording.")
    }
    
    func testStopRecordingWithNilRecorder() async {
        XCTAssertNil(audioRecorder.recorder, "The recorder shouldn't be set.")
        await audioRecorder.stopRecording()
    }
    
    func testPauseRecording() async {
        await startRecording()
        await audioRecorder.pauseRecording()
        XCTAssertFalse(audioRecorder.isRecording, "Audio recorder should not be recording after calling pause.")
    }
    
    func testDeleteRecording() async {
        await startRecording()
        await stopRecording()
        await audioRecorder.deleteRecording()
        XCTAssertNil(audioRecorder.url, "Audio recorder's url should be nil after calling deleteRecording.")
    }
    
    func testDeleteRecordingWhileRecording() async {
        await startRecording()
        await audioRecorder.deleteRecording()
        XCTAssertTrue(audioRecorder.isRecording, "Audio recording should be recording.")
    }
    
    func testDeleteRecordingFails() async {
        recorder.shouldDeleteSuccessfully = false
        await startRecording()
        await stopRecording()
        await audioRecorder.deleteRecording()
    }
}

private extension AudioRecorderTests {
    func startRecording() async {
        await audioRecorder.startRecording(recorder: recorder)
        XCTAssertEqual(audioRecorder.url, recorder.url, "Audio recorder url does't match recorder's url.")
        XCTAssertNotNil(audioRecorder.recorder, "Audio recorder's recorder is nil.")
        XCTAssertTrue(audioRecorder.isRecording, "Audio recorder should be recording.")
    }
    
    func stopRecording() async {
        XCTAssertTrue(audioRecorder.isRecording, "Audio recorder should be recording before calling stop.")
        await audioRecorder.stopRecording()
        XCTAssertFalse(audioRecorder.isRecording, "Audio recorder should not be recording after calling stop.")
    }
}
