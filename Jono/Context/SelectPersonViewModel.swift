//
//  SelectPersonViewModel.swift
//  Jono
//
//  Created by Husnain on 11/03/2024.
//

import Foundation
import Combine

class SelectPersonViewModel: ObservableObject {
    @Published var persons: [Person] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var input = ""
    
    private var personService: PersonService?
    
    init() {
        $input
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] t in
                if !t.isEmpty {
                    self?.search(t)
                } else {
                    self?.persons = self?.personService?.getAll() ?? []
                }
            })
            .store(in: &cancellables)
    }
    
    func setup(personService: PersonService) {
        self.personService = personService
        self.persons = personService.getAll()
    }
    
    func search(_ term: String) {
        self.persons = personService?.search(term) ?? []
    }
}
