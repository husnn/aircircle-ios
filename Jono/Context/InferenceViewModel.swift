//
//  InferenceViewModel.swift
//  Jono
//
//  Created by Husnain on 16/03/2024.
//

import Foundation

class InferenceViewModel: ObservableObject {
    
    @Published var notes: [SuggestedNote] = []
    @Published var isFetching: Bool = false
    
    private var contextService: ContextService? = nil
    
    func setup(contextService: ContextService) {
        self.contextService = contextService
    }
    
    func fetchResult(audioPath: String) async {
        DispatchQueue.main.async { [weak self] in
            self?.isFetching = true
        }
        
        defer {
            DispatchQueue.main.async { [weak self] in
                self?.isFetching = false
            }
        }
        
        do {
            guard let result = try await self.contextService?.handleRecording(fileURL: URL(string: audioPath)!) else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.notes = result.notes
            }
        } catch {
            print("Error handling recording: \(error.localizedDescription)")
        }
    }
}
