//
//  MockAudioRecorder.swift
//  IssueTrackerTests
//
//  Created by Tino on 7/5/2023.
//

import Foundation
@testable import IssueTracker

final class MockAudioRecorder: AudioRecorderProtocol {
    var isRecording: Bool = false
    var url: URL
    var settings: [String: Any] = [:]
    var shouldDeleteSuccessfully = true
    init(url: URL, settings: [String : Any]) throws {
        self.url = url
        self.settings = settings
    }
    
    func prepareToRecord() -> Bool {
        true
    }
    
    func record() -> Bool {
        isRecording = true
        return true
    }
    
    func stop() {
        isRecording = false
    }
    
    func pause() {
        isRecording = false
    }
    
    func deleteRecording() -> Bool {
        shouldDeleteSuccessfully
    }
}
