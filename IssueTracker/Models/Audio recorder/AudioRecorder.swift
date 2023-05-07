//
//  AudioRecorder.swift
//  IssueTracker
//
//  Created by Tino on 9/3/2023.
//

import Foundation
import AVFoundation
import os

final class AudioRecorder: ObservableObject {
    private(set) var recorder: AudioRecorderProtocol?
    @Published private(set) var isRecording = false
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AudioRecorder.self)
    )
    @Published private(set) var url: URL?
    private var session: AVAudioSessionProtocol
    
    init(session: AVAudioSessionProtocol = AVAudioSession.sharedInstance()) {
        self.session = session
        do {
            try session.setCategory(.record)
        } catch {
            logger.error("Failed to init audio recorder.")
        }
    }
}

extension AudioRecorder {
    func requestPermission() -> Bool {
        var hasPermission = false
        session.requestRecordPermission { [weak self] granted in
            guard let self else { return }
            if !granted {
                self.logger.debug("Use denied recording.")
                hasPermission = false
                return
            }
            hasPermission = true
        }
        return hasPermission
    }
    
    @MainActor
    func startRecording(recorder: AudioRecorderProtocol) {
        if !requestPermission() {
            return
        }
        logger.debug("Starting to record audio.")
        
        url = recorder.url
        self.recorder = recorder
        
        if isRecording {
            logger.debug("Already recording.")
            return
        }
        
        recorder.prepareToRecord()
        recorder.record()
        isRecording = recorder.isRecording
    }
    
    @MainActor
    func stopRecording() {
        guard let recorder else {
            logger.debug("Recorder is nil.")
            return
        }
        if !isRecording {
            return
        }
        recorder.stop()
        print("checking if written to disk")
        if FileManager.default.fileExists(atPath: url!.path()) {
            print("The file has been written to disk.")
        }
        isRecording = recorder.isRecording
        logger.debug("Stopped recording.")
    }
    
    @MainActor
    func pauseRecording() {
        guard let recorder else {
            logger.debug("Cannot pause recording recorder is nil.")
            return
        }
        recorder.pause()
        isRecording = recorder.isRecording
    }
    
    @MainActor
    func deleteRecording() {
        guard let recorder else {
            logger.debug("Failed to delete recording. recorder is nil.")
            return
        }
        if isRecording {
            logger.debug("Failed to delete recording. recorder is still recording.")
            return
        }
        let fileWasDeleted = recorder.deleteRecording()
        if !fileWasDeleted {
            logger.error("Failed to delete audio recording.")
        }
        url = nil
        logger.debug("Successfully deleted audio recording.")
    }
}
