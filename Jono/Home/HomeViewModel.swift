//
//  HomeViewModel.swift
//  Jono
//
//  Created by Husnain on 06/03/2024.
//

import Foundation
import UIKit

class HomeViewModel: ObservableObject {
    
    private var contextService: ContextService?
    private var personService: PersonService?
    
    @Published var persons: [Person] = []
    
    private var audioSession: AudioSession?
    
    @Published var missingPermissions: Bool = false
    
    @Published var isRecording: Bool = false {
        didSet {
            if oldValue != isRecording {
                toggleRecording()
            }
        }
    }
    
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    
    @Published var recordingDurationMs: Double = 0
    
    private let maxRecordingDurationMs: Double = 60_000 * 3 // 3 Minutes
    private let minRecordingDurationMs: Double = 1000 * 2 // 2 Seconds
    
    @Published var audioRecordingPath: IdentifiableString? = nil

    func fetchPersons() {
        self.persons = self.personService?.getAll() ?? []
    }
    
    func setup(contextService: ContextService, personService: PersonService) {
        self.contextService = contextService
        self.personService = personService
        
        self.audioSession = AudioSession()
        
        Task {
            guard let session = self.audioSession, await session.getPermissions() else {
                DispatchQueue.main.async { self.missingPermissions = true }
                return
            }
            
            try? self.audioSession?.setup()
        }
    }
    
    private func toggleRecording() {
        if self.missingPermissions {
            Task {
                guard let session = self.audioSession else { return }
                
                if await session.getPermissions() {
                    self.missingPermissions = false
                    try session.setup()
                } else {
                    self.missingPermissions = true
                }
            }
            return
        }
        
        self.isRecording ? self.startRecording() : self.stopRecording()
    }
    
    private func startRecording() {
        print("HomeViewModel.startRecording: Called")
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        self.audioSession?.startRecording()
        
        self.recordingStartTime = Date()
        
        self.recordingTimer = .scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let startTime = self.recordingStartTime {
                self.recordingDurationMs = Date().timeIntervalSince(startTime) * 1000
            }
            
            // Forcefully stop recording
            if self.recordingDurationMs >= self.maxRecordingDurationMs {
                self.isRecording = false
            }
        }
        
        self.recordingTimer?.fire()
    }
    
    private func stopRecording() {
        print("HomeViewModel.stopRecording: Called")
        
        if self.recordingDurationMs < minRecordingDurationMs {
            // TODO: Show "recording too short" message
        }
        
        let durationMs = Int(self.recordingDurationMs)
        let durationSecs = Int(durationMs / 1000)
        
        self.recordingTimer?.invalidate()
        
        self.recordingStartTime = nil
        self.recordingDurationMs = 0
        
        self.audioSession?.stopRecording(minLengthMs: minRecordingDurationMs) { [weak self] output in
            guard let output = output else {
                // Recording too short.
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            self?.audioRecordingPath = IdentifiableString(value: output.absoluteString)
        }
    }
}

struct IdentifiableString: Identifiable {
    let id = UUID()
    var value: String
}
