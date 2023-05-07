//
//  AudioRecorderProtocol.swift
//  IssueTracker
//
//  Created by Tino on 7/5/2023.
//

import AVFoundation

protocol AudioRecorderProtocol {
    init(url: URL, settings: [String : Any]) throws
    
    @discardableResult
    func prepareToRecord() -> Bool
    @discardableResult
    func record() -> Bool
    func stop()
    func pause()
    func deleteRecording() -> Bool
    
    var url: URL { get }
    var settings: [String : Any] { get }
    var isRecording: Bool { get }
}

extension AVAudioRecorder: AudioRecorderProtocol { }
