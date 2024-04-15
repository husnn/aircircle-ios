//
//  AddPersonViewModel.swift
//  Jono
//
//  Created by Husnain on 08/03/2024.
//

import Foundation

class AddPersonViewModel: ObservableObject {
    
    func create(name: String, bio: String) -> Bool {
        var person = Person(name: name, bio: bio)
        
        do {
            try dbPool.write { db in
                try person.insert(db)
            }
            
            return true
        } catch {
            print("Could not insert Person record. \(error.localizedDescription)")
        }
        
        return false
    }
}
