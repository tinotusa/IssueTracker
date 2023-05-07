//
//  MockAudioPlayer.swift
//  IssueTrackerTests
//
//  Created by Tino on 7/5/2023.
//

import AVFoundation
@testable import IssueTracker

class MockAudioPlayer: NSObject, AudioPlayerProtocol, AVAudioPlayerDelegate, AVAudioPlayerDelegateProtocol {
    var url: URL
    
    var audioPlayerDelegate: IssueTracker.AVAudioPlayerDelegateProtocol?
    
    var isPlaying: Bool = false

    required init(contentsOf url: URL) throws {
        self.url = url
    }
    
    func prepareToPlay() -> Bool {
        return true
    }
    
    func play() -> Bool {
        isPlaying = true
        return true
    }
    
    func pause() {
        isPlaying = false
    }
    
    func stop() {
        isPlaying = false
    }
    
    func didFinishPlaying(_ player: IssueTracker.AudioPlayerProtocol, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.didFinishPlaying(player, successfully: flag)
    }
}
