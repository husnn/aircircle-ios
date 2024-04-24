//
//  SearchViewModel.swift
//  Aircircle
//
//  Created by Husnain on 08/03/2024.
//

import Foundation
import Combine
import GRDB

class SearchViewModel: ObservableObject {
    @Published var persons: [Person] = []
    @Published var notes: [NoteResult] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var input = ""
    
    private var personService: PersonService?
    private var contextService: ContextService?
    
    init() {
        $input
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] t in
                if !t.isEmpty {
                    self?.search(t)
                } else {
                    self?.persons = []
                    self?.notes = []
                }
            })
            .store(in: &cancellables)
    }
    
    func setup(personService: PersonService, contextService: ContextService) {
        self.personService = personService
        self.contextService = contextService
    }
    
    func search(_ term: String) {
        print("Searching term: \(term)")
        
        self.persons = personService?.search(term) ?? []
        print("Persons: \(persons.count)")
        
        if term.count >= 3 {
            self.notes = contextService?.search(term) ?? []
        }
    }
}
