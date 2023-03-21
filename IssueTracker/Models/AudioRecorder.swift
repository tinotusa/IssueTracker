//
//  AudioRecorder.swift
//  IssueTracker
//
//  Created by Tino on 9/3/2023.
//

import Foundation
import AVFoundation
import os

class AudioRecorder: ObservableObject {
    private var recorder: AVAudioRecorder?
    @Published private(set) var isRecording = false
    private let log = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AudioRecorder.self)
    )
    @Published private(set) var url: URL?
    private var session: AVAudioSession
    
    init() {
        session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record)
        } catch {
            log.error("Failed to init audio recorder.")
        }
    }
    
    func requestPermission() -> Bool {
        var hasPermission = false
        session.requestRecordPermission { [weak self] granted in
            if !granted {
                self?.log.debug("Use denied recording.")
                hasPermission = false
                return
            }
            hasPermission = true
        }
        return hasPermission
    }
    
    @MainActor
    func startRecording() {
        if !requestPermission() {
            return
        }
        log.debug("Starting to record audio.")
        do {
            let attachmentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "attachmentsFolder")
            if !FileManager.default.fileExists(atPath: attachmentsFolder.path()) {
                try FileManager.default.createDirectory(at: attachmentsFolder, withIntermediateDirectories: true)
            }
            let audioFileURL = attachmentsFolder.appending(path: "\(UUID().uuidString).m4a")
            url = audioFileURL
            recorder = try .init(url: audioFileURL, settings: [:])
            
            if isRecording {
                log.debug("Already recording.")
                return
            }
            
            guard let recorder else {
                log.debug("Failed to start recorder. recorder is nil.")
                return
            }
            
            recorder.prepareToRecord()
            recorder.record()
            isRecording = recorder.isRecording
        } catch {
            log.error("Failed to start recording. \(error)")
        }
    }
    
    @MainActor
    func stopRecording() {
        guard let recorder else {
            log.debug("Recorder is nil.")
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
        log.debug("Stopped recording.")
    }
    
    @MainActor
    func pauseRecording() {
        guard let recorder else {
            log.debug("Cannot pause recording recorder is nil.")
            return
        }
        recorder.pause()
        isRecording = recorder.isRecording
    }
    
    @MainActor
    func deleteRecording() {
        guard let recorder else {
            log.debug("Failed to delete recording. recorder is nil.")
            return
        }
        if isRecording {
            log.debug("Failed to delete recording. recorder is still recording.")
            return
        }
        let fileWasDeleted = recorder.deleteRecording()
        if !fileWasDeleted {
            log.error("Failed to delete audio recording.")
        }
        url = nil
        log.debug("Successfully deleted audio recording.")
    }
}
