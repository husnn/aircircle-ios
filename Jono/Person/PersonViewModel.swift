//
//  PersonViewModel.swift
//  Jono
//
//  Created by Husnain on 10/03/2024.
//

import Foundation

class PersonViewModel: ObservableObject {
    let person: Person
    
    init(person: Person) {
        self.person = person
    }
}
