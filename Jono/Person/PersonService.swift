//
//  PersonService.swift
//  Jono
//
//  Created by Husnain on 08/03/2024.
//

import GRDB
import SwiftUI

class PersonService: ObservableObject {
    func getAll(limit: Int = 10) -> [Person] {
        var persons: [Person] = []
        
        do {
            try dbPool.read { db in
                persons = try Person
                    .order(Column("createdAt").desc)
                    .limit(limit)
                    .fetchAll(db)
            }
        } catch {
            print("Could not get Person records. \(error.localizedDescription)")
        }
        
        return persons
    }
    
    func search(_ term: String) -> [Person] {
        var persons: [Person] = []
        
        do {
            try dbPool.read { db in
                persons = try Person
                    .filter(
                        Column("name").like("%\(term)%")
                    )
                    .fetchAll(db)
            }
        } catch {
            print("Could not search for Person records. \(error.localizedDescription)")
        }
        
        return persons
    }
    
    func delete(_ personId: Int64) -> Bool {
        do {
            _ = try dbPool.write { db in
                try Person.deleteOne(db, id: personId)
            }
            
            return true
        } catch {
            print("Failed to delete Person record. \(error.localizedDescription)")
        }
        
        return false
    }
    
    func setBio(personId: Int64, text: String?) -> Bool {
        do {
            _ = try dbPool.write { db in
                var person = try Person.find(db, id: personId)
                person.bio = text
                try person.update(db)
            }
            
            return true
        } catch {
            print("Failed to delete Person record. \(error.localizedDescription)")
        }
        return false
    }
}
