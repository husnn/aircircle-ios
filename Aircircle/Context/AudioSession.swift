//
//  AudioSession.swift
//  Aircircle
//
//  Created by Husnain on 06/03/2024.
//

import AVFoundation
import SwiftUI

class AudioSession: NSObject {
    var engine: AVAudioEngine!
    var file: AVAudioFile? = nil
    
    var isSetup: Bool = false
    
    private var format: AVAudioFormat?
    
    private let outputFileExtension = "wav"
    
    private var isWriting: Bool = false
    private var startTime: Double?
    private var duration: Double = 0.0
    
    private var recordingDelaySecs: CGFloat = 0.2
    
    func getPermissions() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        case .denied:
            return false
        default:
            return false
        }
    }
    
    func setup() throws {
        print("AudioSession.setup: Called")
        
        self.engine = AVAudioEngine()
        self.format = self.engine.inputNode.outputFormat(forBus: 0)
            
        self.engine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { (buffer, time) -> Void in
            guard self.isWriting && self.file != nil else { return }
            
            do {
                try self.file?.write(from: buffer)
                
                let t = AVAudioTime.seconds(forHostTime: time.hostTime)
                
                if self.startTime == nil {
                    self.startTime = t
                } else {
                    self.duration = t - self.startTime!
                }
            } catch {
                print("Could not write audio buffer to file: \(error.localizedDescription)")
            }
        }
        
        isSetup = true
    }
    
    private func getAudioOutputURL() -> URL {
        .documentsDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(outputFileExtension)
    }
    
    func startRecording() {
        // Prevent display from dimming and locking device.
        UIApplication.shared.isIdleTimerDisabled = true
        
        do {
            if !self.isSetup {
                try self.setup()
            }
            
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Could not start recording: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + recordingDelaySecs) {
            do {
                try self.engine.start()
                
                self.isWriting = true
                
                self.startTime = nil
                self.duration = 0.0
                
                self.file = try AVAudioFile(
                    forWriting: self.getAudioOutputURL(),
                    settings: self.engine.inputNode.inputFormat(forBus: 0).settings
                )
            } catch {
                print("Could not start writing: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func stopRecording(minLengthMs: Double, completion: @escaping (_ output: URL?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + recordingDelaySecs) {
            guard self.isWriting else { return }
            
            self.isWriting = false

            defer {
                self.file = nil
                self.engine.stop()
                
                try? AVAudioSession.sharedInstance().setActive(false)
            }
            
            if self.duration < minLengthMs / 1000 {
                print("stopRecording: Audio too short. Discarding.")
                try! FileManager.default.removeItem(at: self.file!.url)
                
                return completion(nil)
            }
            
            completion(self.file?.url)
            
            print("AudioSession.stopRecording: Done")
        }
        
        // Undo.
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
