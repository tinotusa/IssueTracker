//
//  MockAudioSession.swift
//  IssueTrackerTests
//
//  Created by Tino on 7/5/2023.
//

import AVFoundation
@testable import IssueTracker

class MockAudioSession: AVAudioSessionProtocol {
    private var category: AVAudioSession.Category = .playAndRecord
    var throwSessionError: Bool = false
    
    func setCategory(_ category: AVAudioSession.Category) throws {
        self.category = category
        if throwSessionError {
            throw NSError(domain: "Error thrown", code: 1)
        }
    }
}
