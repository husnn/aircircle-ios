//
//  AddPersonViewModel.swift
//  Jono
//
//  Created by Husnain on 08/03/2024.
//

import Foundation

class AddPersonViewModel: ObservableObject {
    
    private var personService: PersonService?
    
    func create(name: String, bio: String) -> Bool {
        return self.personService?.create(name: name, bio: bio) != nil
    }
    
    func setup(personService: PersonService) {
        self.personService = personService
    }
}
